package contractgen.riscv.isa.extractor;

import contractgen.Extractor;
import contractgen.TestResult;
import contractgen.riscv.isa.RISCVInstruction;
import contractgen.riscv.isa.contract.RISCVObservation;
import contractgen.riscv.isa.contract.RISCVTestResult;
import contractgen.riscv.isa.contract.RISCV_OBSERVATION_TYPE;
import contractgen.util.Pair;
import contractgen.util.StringUtils;
import contractgen.util.vcd.Module;
import contractgen.util.vcd.VcdFile;
import contractgen.util.vcd.Wire;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class BMCExtractor implements Extractor {
    @Override
    public Pair<TestResult, TestResult> extractResults(String PATH, boolean adversaryDistinguishable, int index) {
        VcdFile vcd;
        try {
            vcd = new VcdFile(Files.readString(Path.of(PATH)));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        Set<RISCVObservation> obs1 = new HashSet<>();
        Set<RISCVObservation> obs2 = new HashSet<>();
        Wire valid1 = vcd.getTop().getChild("left").getWire("rvfi_valid");
        Wire valid2 = vcd.getTop().getChild("right").getWire("rvfi_valid");
        Integer t1 = valid1.getFirstTimeValue("1");
        Integer t2 = valid1.getFirstTimeValue("1");
        while (t1 != null && t2 != null) {
            if (!compareInstructions(vcd, t1, t2, obs1, obs2)) {
                // invalid instruction
                t1 = valid1.getFirstTimeValueAfter("1", t1);
                t2 = valid2.getFirstTimeValueAfter("1", t2);
                continue;
            }
            RISCVInstruction instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("left").getWire("rvfi_insn").getValueAt(t1));
            RISCVInstruction instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("right").getWire("rvfi_insn").getValueAt(t2));

            compareRegisters(vcd, t1, t2, instr_1, instr_2, obs1, obs2);
            compareMemory(vcd, t1, t2, instr_1, instr_2, obs1, obs2);
            compareBranch(vcd, t1, t2, instr_1, instr_2, obs1, obs2);

            for (int distance = 1; distance <= 4; distance++) {
                compareDependencies(vcd, t1, t2, distance, instr_1, instr_2, obs1, obs2);
            }
            t1 = valid1.getFirstTimeValueAfter("1", t1);
            t2 = valid2.getFirstTimeValueAfter("1", t2);
        }
        return new Pair<>(new RISCVTestResult(obs1, adversaryDistinguishable, index * 2), new RISCVTestResult(obs2, adversaryDistinguishable, (index * 2) + 1));

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
    private void compareDependencies(VcdFile vcd, Integer t1, Integer t2, int distance, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs1, Set<RISCVObservation> obs2) {
        try {
            // TODO when applicable
            Integer prev_t1 = t1;
            Integer prev_t2 = t2;
            for (int i = 0; i < distance; i++) {
                prev_t1 = vcd.getTop().getChild("left").getWire("rvfi_valid").getFirstTimeValueBefore("1", prev_t1);
                prev_t2 = vcd.getTop().getChild("right").getWire("rvfi_valid").getFirstTimeValueBefore("1", prev_t2);
            }
            RISCVInstruction previous_instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("left").getWire("rvfi_insn").getValueAt(prev_t1));
            RISCVInstruction previous_instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("right").getWire("rvfi_insn").getValueAt(prev_t2));

            if ((instr_1.hasRS1() && instr_2.hasRS1()) && (previous_instr_1.hasRD() && previous_instr_2.hasRD()) && Objects.equals(instr_1.rs1(), previous_instr_1.rd()) && !Objects.equals(instr_2.rs1(), previous_instr_2.rd())) {
                obs1.add(new RISCVObservation(previous_instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
                obs2.add(new RISCVObservation(previous_instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
            }
            if ((instr_1.hasRS1() && instr_2.hasRS1()) && (previous_instr_1.hasRD() && previous_instr_2.hasRD()) && !Objects.equals(instr_1.rs1(), previous_instr_1.rd()) && Objects.equals(instr_2.rs1(), previous_instr_2.rd())) {
                obs1.add(new RISCVObservation(previous_instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
                obs2.add(new RISCVObservation(previous_instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS1, distance)));
            }
            if ((instr_1.hasRS2() && instr_2.hasRS2()) && (previous_instr_1.hasRD() && previous_instr_2.hasRD()) && Objects.equals(instr_1.rs2(), previous_instr_1.rd()) && !Objects.equals(instr_2.rs2(), previous_instr_2.rd())) {
                obs1.add(new RISCVObservation(previous_instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
                obs2.add(new RISCVObservation(previous_instr_1.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
            }
            if ((instr_1.hasRS2() && instr_2.hasRS2()) && (previous_instr_1.hasRD() && previous_instr_2.hasRD()) && !Objects.equals(instr_1.rs2(), previous_instr_1.rd()) && Objects.equals(instr_2.rs2(), previous_instr_2.rd())) {
                obs1.add(new RISCVObservation(previous_instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
                obs2.add(new RISCVObservation(previous_instr_2.type(), getDependencyObservationType(DEPENDENCY.RAW_RS2, distance)));
            }
            if ((instr_1.hasRD() && instr_2.hasRD()) && (previous_instr_1.hasRD() && previous_instr_2.hasRD()) && Objects.equals(instr_1.rd(), previous_instr_1.rd()) && !Objects.equals(instr_2.rd(), previous_instr_2.rd())) {
                obs1.add(new RISCVObservation(previous_instr_1.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
                obs2.add(new RISCVObservation(previous_instr_1.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
            }
            if ((instr_1.hasRD() && instr_2.hasRD()) && (previous_instr_1.hasRD() && previous_instr_2.hasRD()) && !Objects.equals(instr_1.rd(), previous_instr_1.rd()) && Objects.equals(instr_2.rd(), previous_instr_2.rd())) {
                obs1.add(new RISCVObservation(previous_instr_2.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
                obs2.add(new RISCVObservation(previous_instr_2.type(), getDependencyObservationType(DEPENDENCY.WAW, distance)));
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
    private void compareBranch(VcdFile vcd, Integer t1, Integer t2, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs1, Set<RISCVObservation> obs2) {
        Module left = vcd.getTop().getChild("left");
        Module right = vcd.getTop().getChild("right");
        Boolean is_branch_1 = instr_1.isBRANCH() || instr_1.isJUMP();
        Boolean is_branch_2 = instr_2.isBRANCH() || instr_2.isJUMP();
        Boolean branch_taken_1 = Integer.parseInt(left.getChild("ibex_core").getWire("branch_decision").getValueAt(t1 - 15), 2) == 1 || instr_1.isJUMP();
        Boolean branch_taken_2 = Integer.parseInt(right.getChild("ibex_core").getWire("branch_decision").getValueAt(t2 - 15), 2) == 1 || instr_2.isJUMP();
        String new_pc_1 = left.getWire("rvfi_pc_wdata").getValueAt(t1);
        String new_pc_2 = right.getWire("rvfi_pc_wdata").getValueAt(t2);

        if ((instr_1.isCONTROL() && instr_2.isCONTROL()) && !Objects.equals(is_branch_1, is_branch_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_BRANCH));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_BRANCH));
        }
        if ((instr_1.isCONTROL() && instr_2.isCONTROL()) && !Objects.equals(branch_taken_1, branch_taken_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.BRANCH_TAKEN));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.BRANCH_TAKEN));
        }
        if ((instr_1.isCONTROL() && instr_2.isCONTROL()) && !Objects.equals(new_pc_1, new_pc_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.NEW_PC));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.NEW_PC));
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
    private void compareMemory(VcdFile vcd, Integer t1, Integer t2, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs1, Set<RISCVObservation> obs2) {
        Module left = vcd.getTop().getChild("left");
        Module right = vcd.getTop().getChild("right");
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
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_ADDR));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_ADDR));
        }
        if ((instr_1.isLOAD() && instr_2.isLOAD()) && !Objects.equals(mem_r_data_1, mem_r_data_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_R_DATA));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_R_DATA));
        }
        if ((instr_1.isSTORE() && instr_2.isSTORE()) && !Objects.equals(mem_w_data_1, mem_w_data_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.MEM_W_DATA));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.MEM_W_DATA));
        }
        if ((instr_1.isMEM() && instr_2.isMEM()) && !Objects.equals(is_aligned_1, is_aligned_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_ALIGNED));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_ALIGNED));
        }
        if ((instr_1.isMEM() && instr_2.isMEM()) && !Objects.equals(is_half_aligned_1, is_half_aligned_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IS_HALF_ALIGNED));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IS_HALF_ALIGNED));
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
    private void compareRegisters(VcdFile vcd, Integer t1, Integer t2, RISCVInstruction instr_1, RISCVInstruction instr_2, Set<RISCVObservation> obs1, Set<RISCVObservation> obs2) {
        Module left = vcd.getTop().getChild("left");
        Module right = vcd.getTop().getChild("right");
        String reg_rs1_1 = left.getWire("rvfi_rs1_rdata").getValueAt(t1);
        String reg_rs1_2 = right.getWire("rvfi_rs1_rdata").getValueAt(t2);
        String reg_rs2_1 = left.getWire("rvfi_rs2_rdata").getValueAt(t1);
        String reg_rs2_2 = right.getWire("rvfi_rs2_rdata").getValueAt(t2);
        String reg_rd_1 = left.getWire("rvfi_rd_wdata").getValueAt(t1);
        String reg_rd_2 = right.getWire("rvfi_rd_wdata").getValueAt(t2);

        if ((instr_1.hasRS1() && instr_2.hasRS1()) && !Objects.equals(reg_rs1_1, reg_rs1_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS1));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS1));
        }
        if ((instr_1.hasRS2() && instr_2.hasRS2()) && !Objects.equals(reg_rs2_1, reg_rs2_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RS2));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RS2));
        }
        if ((instr_1.hasRD() && instr_2.hasRD()) && !Objects.equals(reg_rd_1, reg_rd_2)) {
            obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.REG_RD));
            obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.REG_RD));
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
    private boolean compareInstructions(VcdFile vcd, Integer t1, Integer t2, Set<RISCVObservation> obs1, Set<RISCVObservation> obs2) {
        RISCVInstruction instr_1;
        RISCVInstruction instr_2;
        try {
            instr_1 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("left").getWire("rvfi_insn").getValueAt(t1));
            instr_2 = RISCVInstruction.parseBinaryString(vcd.getTop().getChild("right").getWire("rvfi_insn").getValueAt(t2));

            //if (!Objects.equals(instr_1.type(), instr_2.type())) {
            //    obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.OPCODE));
            //    obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.OPCODE));
            //}

            if (!Objects.equals(instr_1.type().getFormat(), instr_2.type().getFormat())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.FORMAT));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.FORMAT));
            }

            if (!Objects.equals(instr_1.type().getOpcode(), instr_2.type().getOpcode())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.OPCODE));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.OPCODE));
            }

            if (!Objects.equals(instr_1.type().getFunct3(), instr_2.type().getFunct3())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.FUNCT3));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.FUNCT3));
            }

            if (!Objects.equals(instr_1.type().getFunct7(), instr_2.type().getFunct7())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.FUNCT7));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.FUNCT7));
            }

            if ((instr_1.hasRD() && instr_2.hasRD()) && !Objects.equals(instr_1.rd(), instr_2.rd())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.RD));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.RD));
            }
            if ((instr_1.hasRS1() && instr_2.hasRS1()) && !Objects.equals(instr_1.rs1(), instr_2.rs1())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.RS1));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.RS1));
            }
            if ((instr_1.hasRS2() && instr_2.hasRS2()) && !Objects.equals(instr_1.rs2(), instr_2.rs2())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.RS2));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.RS2));
            }
            if ((instr_1.hasIMM() && instr_2.hasIMM()) && !Objects.equals(instr_1.imm(), instr_2.imm())) {
                obs1.add(new RISCVObservation(instr_1.type(), RISCV_OBSERVATION_TYPE.IMM));
                obs2.add(new RISCVObservation(instr_2.type(), RISCV_OBSERVATION_TYPE.IMM));
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
