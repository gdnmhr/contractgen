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

/**
 * Extracts possible contract observations from the RVFI intere.
 */
public class RVFIExtractor implements Extractor {

    private Set<RISCV_OBSERVATION_TYPE> allowed_observations;

    private boolean isSP;
    private boolean useUnsafeInstructions;
    private Set<RISCV_TYPE> unsafeInstructions;

    public RVFIExtractor(Set<RISCV_OBSERVATION_TYPE> allowed_observations, boolean isSP) {
        this.allowed_observations = allowed_observations;
        this.isSP = isSP;
        this.useUnsafeInstructions = false;
        this.unsafeInstructions = Set.of();
    }

    public RVFIExtractor(Set<RISCV_OBSERVATION_TYPE> allowed_observations, boolean isSP, Set<RISCV_TYPE> unsafeInstructions) {
        this.allowed_observations = allowed_observations;
        this.isSP = isSP;
        this.useUnsafeInstructions = true;
        this.unsafeInstructions = unsafeInstructions;
    }

    @Override
    public TestResult extractResults(String PATH, boolean adversaryDistinguishable, int index) {
        boolean containedUnsafeInstruction = false;
        VcdFile vcd;
        try {
            vcd = new VcdFile(Files.readString(Path.of(PATH + "sim.vcd")));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        Set<RISCVObservation> obs = new HashSet<>();
        Set<Pair<RISCV_TYPE, RISCV_TYPE>> distinguishingInstructions = new HashSet<>();
        Wire retire_count = vcd.getTop().getChild("control").getWire("retire_count");
        int currentCount = Integer.parseInt(retire_count.getValueAt(retire_count.getLastChangeTime()), 2);
        int limit = isSP ? 31 : 0;
        while (currentCount > limit) {
            Integer retire_time = retire_count.getFirstTimeValue(StringUtils.toBinaryEncoding((long) currentCount));

            if (!compareInstructions(vcd, retire_time, obs, distinguishingInstructions)) {
                // invalid instruction
                currentCount--;
                continue;
            }
            RISCVInstruction instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("ctr").getWire("instr_1_i").getValueAt(retire_time));
            RISCVInstruction instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("ctr").getWire("instr_2_i").getValueAt(retire_time));

            if (unsafeInstructions.contains(instr_1.type()) || unsafeInstructions.contains(instr_2.type())) {
                containedUnsafeInstruction = true;
            }

            compareRegisters(vcd, retire_time, instr_1, instr_2, obs);
            compareMemory(vcd, retire_time, instr_1, instr_2, obs);
            compareBranch(vcd, retire_time, instr_1, instr_2, obs);

            for (int distance = 1; distance <= 4; distance++) {
                compareDependencies(vcd, retire_count, currentCount, distance, instr_1, instr_2, obs);
            }
            currentCount--;
        }        
        obs= obs.stream().filter(o -> allowed_observations.contains(o.observation())).collect(Collectors.toSet());
        return new RISCVTestResult(obs, distinguishingInstructions, useUnsafeInstructions ? containedUnsafeInstruction : adversaryDistinguishable, index);
    }

    /**
     * @param vcd          The VCD file.
     * @param retire_count the wire counting retirements.
     * @param currentCount the instruction currently being analyzed.
     * @param distance     the distance currently under inspection.
     * @param instr_1      the first instruction.
     * @param instr_2      the second instruction.
     * @param obs1         the current set of observations for execution one.
     * @param obs2         the current set of observations for execution two.
     */
    private void compareDependencies(VcdFile vcd, Wire retire_count, Integer currentCount, int distance, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        try {
            Integer previous_retire_time = retire_count.getFirstTimeValue(StringUtils.toBinaryEncoding((long) currentCount - distance));
            if (previous_retire_time == null) {
                return;
            }
            RISCVInstruction previous_instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("ctr").getWire("instr_1_i").getValueAt(previous_retire_time));
            RISCVInstruction previous_instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("ctr").getWire("instr_2_i").getValueAt(previous_retire_time));

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
     * @param vcd         the VCD file.
     * @param retire_time the retire time of the given instructions.
     * @param instr_1     the first instruction.
     * @param instr_2     the second instruction.
     * @param obs1        the current set of observations for execution one.
     * @param obs2        the current set of observations for execution two.
     */
    private void compareBranch(VcdFile vcd, Integer retire_time, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        Module ctr = vcd.getTop().getChild("ctr");
        String is_branch_1 = ctr.getWire("is_branch_1").getValueAt(retire_time);
        String is_branch_2 = ctr.getWire("is_branch_2").getValueAt(retire_time);
        String branch_taken_1 = ctr.getWire("branch_taken_1").getValueAt(retire_time);
        String branch_taken_2 = ctr.getWire("branch_taken_2").getValueAt(retire_time);
        String new_pc_1 = ctr.getWire("new_pc_1").getValueAt(retire_time);
        String new_pc_2 = ctr.getWire("new_pc_2").getValueAt(retire_time);

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
     * @param vcd         the VCD file.
     * @param retire_time the retire time of the given instructions.
     * @param instr_1     the first instruction.
     * @param instr_2     the second instruction.
     * @param obs1        the current set of observations for execution one.
     * @param obs2        the current set of observations for execution two.
     */
    private void compareMemory(VcdFile vcd, Integer retire_time, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        Module ctr = vcd.getTop().getChild("ctr");
        String mem_addr_1 = ctr.getWire("mem_addr_1").getValueAt(retire_time);
        String mem_addr_2 = ctr.getWire("mem_addr_2").getValueAt(retire_time);
        String mem_r_data_1 = ctr.getWire("mem_r_data_1").getValueAt(retire_time);
        String mem_r_data_2 = ctr.getWire("mem_r_data_2").getValueAt(retire_time);
        String mem_w_data_1 = ctr.getWire("mem_w_data_1").getValueAt(retire_time);
        String mem_w_data_2 = ctr.getWire("mem_w_data_2").getValueAt(retire_time);
        String is_aligned_1 = ctr.getWire("is_aligned_1").getValueAt(retire_time);
        String is_aligned_2 = ctr.getWire("is_aligned_2").getValueAt(retire_time);
        String is_half_aligned_1 = ctr.getWire("is_half_aligned_1").getValueAt(retire_time);
        String is_half_aligned_2 = ctr.getWire("is_half_aligned_2").getValueAt(retire_time);

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
     * @param vcd         the VCD file.
     * @param retire_time the retire time of the given instructions.
     * @param instr_1     the first instruction.
     * @param instr_2     the second instruction.
     * @param obs1        the current set of observations for execution one.
     * @param obs2        the current set of observations for execution two.
     */
    private void compareRegisters(VcdFile vcd, Integer retire_time, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs) {
        Module ctr = vcd.getTop().getChild("ctr");
        String reg_rs1_1 = ctr.getWire("reg_rs1_1").getValueAt(retire_time);
        String reg_rs1_2 = ctr.getWire("reg_rs1_2").getValueAt(retire_time);
        String reg_rs2_1 = ctr.getWire("reg_rs2_1").getValueAt(retire_time);
        String reg_rs2_2 = ctr.getWire("reg_rs2_2").getValueAt(retire_time);
        String reg_rd_1 = ctr.getWire("reg_rd_1").getValueAt(retire_time);
        String reg_rd_2 = ctr.getWire("reg_rd_2").getValueAt(retire_time);

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
     * @param vcd         the VCD file.
     * @param retire_time the retire time of the given instructions.
     * @param obs1        the current set of observations for execution one.
     * @param obs2        the current set of observations for execution two.
     * @return whether any error occurred.
     */
    private boolean compareInstructions(VcdFile vcd, Integer retire_time, Set<RISCVObservation> obs, Set<Pair<RISCV_TYPE, RISCV_TYPE>> distinguishingInstructions) {
        RISCVInstruction instr_1;
        RISCVInstruction instr_2;
        try {
            instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("ctr").getWire("instr_1_i").getValueAt(retire_time));
            instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("ctr").getWire("instr_2_i").getValueAt(retire_time));

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
