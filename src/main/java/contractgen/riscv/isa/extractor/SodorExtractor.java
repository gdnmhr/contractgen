package contractgen.riscv.isa.extractor;

import contractgen.Extractor;
import contractgen.TestResult;
import contractgen.riscv.isa.RISCVInstruction;
import contractgen.riscv.isa.RISCV_TYPE;
import contractgen.riscv.isa.contract.RISCVObservation;
import contractgen.riscv.isa.contract.RISCVTestResult;
import contractgen.riscv.isa.contract.RISCV_OBSERVATION_TYPE;
import contractgen.util.Pair;
import contractgen.util.StringUtils;
import contractgen.util.vcd.Module;
import contractgen.util.vcd.VcdFile;
import contractgen.util.vcd.Wire;

import java.util.stream.Collectors;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class SodorExtractor implements Extractor {

    private Set<RISCV_OBSERVATION_TYPE> allowed_observations;

    public SodorExtractor(Set<RISCV_OBSERVATION_TYPE> allowed_observations) {
        this.allowed_observations = allowed_observations;
    }

    @Override
    public TestResult extractResults(String PATH, boolean adversaryDistinguishable, int index) {
        VcdFile vcd;
        try {
            vcd = new VcdFile(Files.readString(Path.of(PATH)));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        Set<RISCVObservation> obs = new HashSet<>();
        Set<Pair<RISCV_TYPE, RISCV_TYPE>> distinguishingInstructions = new HashSet<>();
        Wire valid1 = vcd.getTop().getChild("left").getChild("Core_2stage").getWire("rvfi_valid");
        Wire valid2 = vcd.getTop().getChild("right").getChild("Core_2stage").getWire("rvfi_valid");
        Wire order1 = vcd.getTop().getChild("left").getChild("Core_2stage").getWire("rvfi_order");
        Wire order2 = vcd.getTop().getChild("right").getChild("Core_2stage").getWire("rvfi_order");
        int expected_order = 1;
        Integer t1 = order1.getFirstTimeValue(Integer.toBinaryString(expected_order));
        Integer t2 = order2.getFirstTimeValue(Integer.toBinaryString(expected_order));
        while (t1 != null && t2 != null) {
            if (!valid1.getValueAt(t1).equals("1") || !valid2.getValueAt(t2).equals("1")) {
                throw new IllegalStateException("both rvfi should be valid.");
            }
            if (compareInstructions(vcd, t1, t2, obs, distinguishingInstructions)) {
                // valid instruction
                
                RISCVInstruction instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("left").getChild("Core_2stage").getWire("rvfi_insn").getValueAt(t1));
                RISCVInstruction instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("right").getChild("Core_2stage").getWire("rvfi_insn").getValueAt(t2));

                compareRegisters(vcd, t1, t2, instr_1, instr_2, obs);
                compareMemory(vcd, t1, t2, instr_1, instr_2, obs);
                compareBranch(vcd, t1, t2, instr_1, instr_2, obs);

                for (int distance = 1; distance <= 4; distance++) {
                    compareDependencies(vcd, t1, t2, distance, instr_1, instr_2, obs);
                }
            }
            expected_order++;
            t1 = order1.getFirstTimeValue(Integer.toBinaryString(expected_order));
            t2 = order2.getFirstTimeValue(Integer.toBinaryString(expected_order));
        }
        obs = obs.stream().filter(o -> allowed_observations.contains(o.observation())).collect(Collectors.toSet());
        return new RISCVTestResult(obs, distinguishingInstructions, adversaryDistinguishable, index);

    }

    /**
     * @param vcd      The VCD file.
     * @param t1       Retire time in the first core
     * @param t2       Retire time in the second core
     * @param distance the distance currently under inspection.
     * @param instr_1  the first instruction.
     * @param instr_2  the second instruction.
     * @param obs1     the current set of observations for execution one.
     * @param obs2     the current set of observations for execution two.
     */
    private void compareDependencies(VcdFile vcd, Integer t1, Integer t2, int distance, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        try {
            Integer prev_t1 = t1;
            Integer prev_t2 = t2;
            for (int i = 0; i < distance; i++) {
                prev_t1 = vcd.getTop().getChild("left").getChild("Core_2stage").getWire("rvfi_valid").getFirstTimeValueBefore("1", prev_t1);
                prev_t2 = vcd.getTop().getChild("right").getChild("Core_2stage").getWire("rvfi_valid").getFirstTimeValueBefore("1", prev_t2);
            }
            if (prev_t1 == null || prev_t2 == null) {
                return;
            }
            RISCVInstruction previous_instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("left").getChild("Core_2stage").getWire("rvfi_insn").getValueAt(prev_t1));
            RISCVInstruction previous_instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("right").getChild("Core_2stage").getWire("rvfi_insn").getValueAt(prev_t2));

            if (previous_instr_1 == null || previous_instr_2 == null) {
                return;
            }

            if ((instr_1.hasRS1() && previous_instr_1.hasRD()) && (instr_2.hasRS1() && previous_instr_2.hasRD()) && (Objects.equals(instr_1.rs1(), previous_instr_1.rd()) != Objects.equals(instr_2.rs1(), previous_instr_2.rd()))) {
                obs.add(new RISCVObservation(instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
                obs.add(new RISCVObservation(instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
            }
            if ((instr_1.hasRS1() && previous_instr_1.hasRD()) && !(instr_2.hasRS1() && previous_instr_2.hasRD())) {
                obs.add(new RISCVObservation(instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
            }
            if (!(instr_1.hasRS1() && previous_instr_1.hasRD()) && (instr_2.hasRS1() && previous_instr_2.hasRD())) {
                obs.add(new RISCVObservation(instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
            }

            if ((instr_1.hasRS2() && previous_instr_1.hasRD()) && (instr_2.hasRS2() && previous_instr_2.hasRD()) && (Objects.equals(instr_1.rs2(), previous_instr_1.rd()) != Objects.equals(instr_2.rs2(), previous_instr_2.rd()))) {
                obs.add(new RISCVObservation(instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
                obs.add(new RISCVObservation(instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
            }
            if ((instr_1.hasRS2() && previous_instr_1.hasRD()) && !(instr_2.hasRS2() && previous_instr_2.hasRD())) {
                obs.add(new RISCVObservation(instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
            }
            if (!(instr_1.hasRS2() && previous_instr_1.hasRD()) && (instr_2.hasRS2() && previous_instr_2.hasRD())) {
                obs.add(new RISCVObservation(instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
            }

            if ((instr_1.hasRD() && previous_instr_1.hasRD()) && (instr_2.hasRD() && previous_instr_2.hasRD()) && (Objects.equals(instr_1.rd(), previous_instr_1.rd()) != Objects.equals(instr_2.rd(), previous_instr_2.rd()))) {
                obs.add(new RISCVObservation(instr_1.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
                obs.add(new RISCVObservation(instr_2.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
            }
            if ((instr_1.hasRD() && previous_instr_1.hasRD()) && !(instr_2.hasRD() && previous_instr_2.hasRD())) {
                obs.add(new RISCVObservation(instr_1.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
            }
            if (!(instr_1.hasRD() && previous_instr_1.hasRD()) && (instr_2.hasRD() && previous_instr_2.hasRD())) {
                obs.add(new RISCVObservation(instr_2.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
            }
        } catch (Exception ignored) {

        }
    }

    /**
     * @param vcd     the VCD file.
     * @param t1      Retire time in the first core
     * @param t2      Retire time in the second core
     * @param instr_1 the first instruction.
     * @param instr_2 the second instruction.
     * @param obs1    the current set of observations for execution one.
     * @param obs2    the current set of observations for execution two.
     */
    private void compareBranch(VcdFile vcd, Integer t1, Integer t2, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        Module left = vcd.getTop().getChild("left");
        Module right = vcd.getTop().getChild("right");
        Boolean is_branch_1 = instr_1.isBRANCH() || instr_1.isJUMP();
        Boolean is_branch_2 = instr_2.isBRANCH() || instr_2.isJUMP();
        Boolean branch_taken_1 = Integer.parseInt(left.getChild("Core_2stage").getWire("branch_taken").getValueAt(t1), 2) == 1 || instr_1.isJUMP();
        Boolean branch_taken_2 = Integer.parseInt(right.getChild("Core_2stage").getWire("branch_taken").getValueAt(t2), 2) == 1 || instr_2.isJUMP();
        String new_pc_1 = left.getChild("Core_2stage").getWire("rvfi_pc_wdata").getValueAt(t1);
        String new_pc_2 = right.getChild("Core_2stage").getWire("rvfi_pc_wdata").getValueAt(t2);

        if ((instr_1.isCONTROL() && instr_2.isCONTROL()) && !Objects.equals(is_branch_1, is_branch_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_BRANCH));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_BRANCH));
        }
        if ((instr_1.isCONTROL() && !instr_2.isCONTROL())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_BRANCH));
        }
        if ((!instr_1.isCONTROL() && instr_2.isCONTROL())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_BRANCH));
        }

        if ((instr_1.isCONTROL() && instr_2.isCONTROL()) && !Objects.equals(branch_taken_1, branch_taken_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.BRANCH_TAKEN));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.BRANCH_TAKEN));
        }
        if ((instr_1.isCONTROL() && !instr_2.isCONTROL())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.BRANCH_TAKEN));
        }
        if ((!instr_1.isCONTROL() && instr_2.isCONTROL())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.BRANCH_TAKEN));
        }

        if ((instr_1.isCONTROL() && instr_2.isCONTROL()) && !Objects.equals(new_pc_1, new_pc_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.NEW_PC));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.NEW_PC));
        }
        if ((instr_1.isCONTROL() && !instr_2.isCONTROL())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.NEW_PC));
        }
        if ((!instr_1.isCONTROL() && instr_2.isCONTROL())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.NEW_PC));
        }
    }

    /**
     * @param vcd     the VCD file.
     * @param t1      Retire time in the first core
     * @param t2      Retire time in the second core
     * @param instr_1 the first instruction.
     * @param instr_2 the second instruction.
     * @param obs1    the current set of observations for execution one.
     * @param obs2    the current set of observations for execution two.
     */
    private void compareMemory(VcdFile vcd, Integer t1, Integer t2, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        Module left = vcd.getTop().getChild("left").getChild("Core_2stage");
        Module right = vcd.getTop().getChild("right").getChild("Core_2stage");
        String mem_addr_1 = left.getWire("rvfi_mem_addr").getValueAt(t1);
        String mem_addr_2 = right.getWire("rvfi_mem_addr").getValueAt(t2);
        String mem_r_data_1 = left.getWire("rvfi_mem_rdata").getValueAt(t1);
        String mem_r_data_2 = right.getWire("rvfi_mem_rdata").getValueAt(t2);
        String mem_w_data_1 = left.getWire("rvfi_mem_wdata").getValueAt(t1);
        String mem_w_data_2 = right.getWire("rvfi_mem_wdata").getValueAt(t2);
        Boolean is_aligned_1 = Long.parseLong(mem_addr_1, 2) % 4 == 0;
        Boolean is_aligned_2 = Long.parseLong(mem_addr_2, 2) % 4 == 0;
        Boolean is_half_aligned_1 = !(Long.parseLong(mem_addr_1, 2) % 4 == 3);
        Boolean is_half_aligned_2 = !(Long.parseLong(mem_addr_2, 2) % 4 == 3);

        if ((instr_1.isMEM() && instr_2.isMEM()) && !Objects.equals(mem_addr_1, mem_addr_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_ADDR));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_ADDR));
        }
        if ((instr_1.isMEM() && !instr_2.isMEM())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_ADDR));
        }
        if ((!instr_1.isMEM() && instr_2.isMEM())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_ADDR));
        }

        if ((instr_1.isLOAD() && instr_2.isLOAD()) && !Objects.equals(mem_r_data_1, mem_r_data_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_R_DATA));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_R_DATA));
        }
        if ((instr_1.isLOAD() && !instr_2.isLOAD())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_R_DATA));
        }
        if ((!instr_1.isLOAD() && instr_2.isLOAD())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_R_DATA));
        }

        if ((instr_1.isSTORE() && instr_2.isSTORE()) && !Objects.equals(mem_w_data_1, mem_w_data_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_W_DATA));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_W_DATA));
        }
        if ((instr_1.isSTORE() && !instr_2.isSTORE())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_W_DATA));
        }
        if ((!instr_1.isSTORE() && instr_2.isSTORE())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_W_DATA));
        }

        if ((instr_1.isMEM() && instr_2.isMEM()) && !Objects.equals(is_aligned_1, is_aligned_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_ALIGNED));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_ALIGNED));
        }
        if ((instr_1.isMEM() && !instr_2.isMEM())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_ALIGNED));
        }
        if ((!instr_1.isMEM() && instr_2.isMEM())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_ALIGNED));
        }

        if ((instr_1.isMEM() && instr_2.isMEM()) && !Objects.equals(is_half_aligned_1, is_half_aligned_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_HALF_ALIGNED));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_HALF_ALIGNED));
        }
        if ((instr_1.isMEM() && !instr_2.isMEM())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_HALF_ALIGNED));
        }
        if ((!instr_1.isMEM() && instr_2.isMEM())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_HALF_ALIGNED));
        }
    }

    /**
     * @param vcd     the VCD file.
     * @param t1      Retire time in the first core
     * @param t2      Retire time in the second core
     * @param instr_1 the first instruction.
     * @param instr_2 the second instruction.
     * @param obs1    the current set of observations for execution one.
     * @param obs2    the current set of observations for execution two.
     */
    private void compareRegisters(VcdFile vcd, Integer t1, Integer t2, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        Module left = vcd.getTop().getChild("left").getChild("Core_2stage");
        Module right = vcd.getTop().getChild("right").getChild("Core_2stage");
        String reg_rs1_1 = left.getWire("rvfi_rs1_rdata").getValueAt(t1);
        String reg_rs1_2 = right.getWire("rvfi_rs1_rdata").getValueAt(t2);
        String reg_rs2_1 = left.getWire("rvfi_rs2_rdata").getValueAt(t1);
        String reg_rs2_2 = right.getWire("rvfi_rs2_rdata").getValueAt(t2);
        String reg_rd_1 = left.getWire("rvfi_rd_wdata").getValueAt(t1);
        String reg_rd_2 = right.getWire("rvfi_rd_wdata").getValueAt(t2);

        if ((instr_1.hasRS1() && instr_2.hasRS1()) && !Objects.equals(reg_rs1_1, reg_rs1_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS1));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS1));
        }
        if ((instr_1.hasRS1() && !instr_2.hasRS1())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS1));
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS1_ZERO));
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS1_LOG2));
        }
        if ((!instr_1.hasRS1() && instr_2.hasRS1())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS1));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS1_ZERO));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS1_LOG2));
        }
        if (instr_1.hasRS1() && instr_2.hasRS1() && StringUtils.fromBinary(reg_rs1_1) == 0 && !(StringUtils.fromBinary(reg_rs1_2) == 0)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS1_ZERO));
        }
        if (instr_1.hasRS1() && instr_2.hasRS1() && !(StringUtils.fromBinary(reg_rs1_1) == 0) && StringUtils.fromBinary(reg_rs1_2) == 0) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS1_ZERO));
        }
        if (instr_1.hasRS1() && instr_2.hasRS1() && (int)(Math.log(StringUtils.fromBinary(reg_rs1_1)) / Math.log(2)) != (int)(Math.log(StringUtils.fromBinary(reg_rs1_2)) / Math.log(2))) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS1_LOG2));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS1_LOG2));
        }

        if ((instr_1.hasRS2() && instr_2.hasRS2()) && !Objects.equals(reg_rs2_1, reg_rs2_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS2));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS2));
        }
        if ((instr_1.hasRS2() && !instr_2.hasRS2())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS2));
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS2_ZERO));
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS2_LOG2));
        }
        if ((!instr_1.hasRS2() && instr_2.hasRS2())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS2));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS2_ZERO));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS2_LOG2));
        }
        if (instr_1.hasRS2() && instr_2.hasRS2() && StringUtils.fromBinary(reg_rs2_1) == 0 && !(StringUtils.fromBinary(reg_rs2_2) == 0)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS2_ZERO));
        }
        if (instr_1.hasRS2() && instr_2.hasRS2() && !(StringUtils.fromBinary(reg_rs2_1) == 0) && StringUtils.fromBinary(reg_rs2_2) == 0) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS2_ZERO));
        }
        if (instr_1.hasRS2() && instr_2.hasRS2() && (int)(Math.log(StringUtils.fromBinary(reg_rs2_1)) / Math.log(2)) != (int)(Math.log(StringUtils.fromBinary(reg_rs2_2)) / Math.log(2))) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS2_LOG2));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS2_LOG2));
        }

        if ((instr_1.hasRD() && instr_2.hasRD()) && !Objects.equals(reg_rd_1, reg_rd_2)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RD));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RD));
        }
        if ((instr_1.hasRD() && !instr_2.hasRD())) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RD));
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RD_ZERO));
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RD_LOG2));
        }
        if ((!instr_1.hasRD() && instr_2.hasRD())) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RD));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RD_ZERO));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RD_LOG2));
        }
        if (instr_1.hasRD() && instr_2.hasRD() && StringUtils.fromBinary(reg_rd_1) == 0 && !(StringUtils.fromBinary(reg_rd_2) == 0)) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RD_ZERO));
        }
        if (instr_1.hasRD() && instr_2.hasRD() && !(StringUtils.fromBinary(reg_rd_1) == 0) && StringUtils.fromBinary(reg_rd_2) == 0) {
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RD_ZERO));
        }
        if (instr_1.hasRD() && instr_2.hasRD() && (int)(Math.log(StringUtils.fromBinary(reg_rd_1)) / Math.log(2)) != (int)(Math.log(StringUtils.fromBinary(reg_rd_2)) / Math.log(2))) {
            obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RD_LOG2));
            obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RD_LOG2));
        }
    }

    /**
     * @param vcd  the VCD file.
     * @param t1   Retire time in the first core
     * @param t2   Retire time in the second core
     * @param obs1 the current set of observations for execution one.
     * @param obs2 the current set of observations for execution two.
     * @return whether any error occurred.
     */
    private boolean compareInstructions(VcdFile vcd, Integer t1, Integer t2, Set<RISCVObservation> obs, Set<Pair<RISCV_TYPE, RISCV_TYPE>> distinguishingInstructions) {
        RISCVInstruction instr_1;
        RISCVInstruction instr_2;
        try {
            instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("left").getChild("Core_2stage").getWire("rvfi_insn").getValueAt(t1));
            instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("right").getChild("Core_2stage").getWire("rvfi_insn").getValueAt(t2));

            if (!Objects.equals(instr_1.type(), instr_2.type())) {
                distinguishingInstructions.add(new Pair<RISCV_TYPE, RISCV_TYPE>(instr_1.type(), instr_2.type()));
            }

            if (!Objects.equals(instr_1.type().getFormat(), instr_2.type().getFormat())) {
                obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.FORMAT));
                obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.FORMAT));
            }

            if (!Objects.equals(instr_1.type().getOpcode(), instr_2.type().getOpcode())) {
                obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.OPCODE));
                obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.OPCODE));
            }

            if (!Objects.equals(instr_1.type().getFunct3(), instr_2.type().getFunct3())) {
                if (instr_1.type().hasFunct3()) {
                    obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.FUNCT3));
                }
                if (instr_2.type().hasFunct3()) {
                    obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.FUNCT3));
                }
            }

            if (!Objects.equals(instr_1.type().getFunct7(), instr_2.type().getFunct7())) {
                if (instr_1.type().hasFunct7()) {
                    obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.FUNCT7));
                }
                if (instr_2.type().hasFunct7()) {
                    obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.FUNCT7));
                }
            }

            if (!Objects.equals(instr_1.rd(), instr_2.rd())) {
                if (instr_1.hasRD()) {
                    obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.RD));
                }
                if (instr_2.hasRD()) {
                    obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.RD));
                }
            }
            if (!Objects.equals(instr_1.rs1(), instr_2.rs1())) {
                if (instr_1.hasRS1()) {
                    obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.RS1));
                }
                if (instr_2.hasRS1()) {
                    obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.RS1));
                }
            }
            if (!Objects.equals(instr_1.rs2(), instr_2.rs2())) {
                if (instr_1.hasRS2()) {
                    obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.RS2));
                }
                if (instr_2.hasRS2()) {
                    obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.RS2));
                }
            }
            if (!Objects.equals(instr_1.imm(), instr_2.imm())) {
                if (instr_1.hasIMM()) {
                    obs.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IMM));
                }
                if (instr_2.hasIMM()) {
                    obs.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IMM));
                }
            }
            return true;
        } catch (Exception e) {
            // invalid instruction
            return false;
        }
    }

    /**
     * The considered types of dependencies.
     */
    private enum DEPENDENCY {
        /**
         * Read-After-Write on RS1.
         */
        RAW_RS1,
        /**
         * Read-After-Write on RS2.
         */
        RAW_RS2,
        /**
         * Write-After-Write
         */
        WAW
    }

    /**
     * @param dep      the dependency
     * @param distance the distance
     * @return the respective observation.
     */
    private RISCV_OBSERVATION_TYPE getDependencyObservationType(DEPENDENCY dep, int distance) {
        switch (dep) {
            case RAW_RS1 -> {
                if (distance == 1) return RISCV_OBSERVATION_TYPE.RAW_RS1_1;
                if (distance == 2) return RISCV_OBSERVATION_TYPE.RAW_RS1_2;
                if (distance == 3) return RISCV_OBSERVATION_TYPE.RAW_RS1_3;
                if (distance == 4) return RISCV_OBSERVATION_TYPE.RAW_RS1_4;
            }
            case RAW_RS2 -> {
                if (distance == 1) return RISCV_OBSERVATION_TYPE.RAW_RS2_1;
                if (distance == 2) return RISCV_OBSERVATION_TYPE.RAW_RS2_2;
                if (distance == 3) return RISCV_OBSERVATION_TYPE.RAW_RS2_3;
                if (distance == 4) return RISCV_OBSERVATION_TYPE.RAW_RS2_4;
            }
            case WAW -> {
                if (distance == 1) return RISCV_OBSERVATION_TYPE.WAW_1;
                if (distance == 2) return RISCV_OBSERVATION_TYPE.WAW_2;
                if (distance == 3) return RISCV_OBSERVATION_TYPE.WAW_3;
                if (distance == 4) return RISCV_OBSERVATION_TYPE.WAW_4;
            }
        }
        return null;
    }
}
