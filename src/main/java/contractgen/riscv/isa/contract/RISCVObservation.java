package contractgen.riscv.isa.contract;

import contractgen.Observation;
import contractgen.ObservationType;
import contractgen.Type;
import contractgen.riscv.isa.RISCVInstruction;
import contractgen.riscv.isa.RISCV_TYPE;

/**
 * An onservation for the RISC-V ISA.
 *
 * @param type        The type of instruction this observation should be associated to.
 * @param observation The observation type.
 */
public record RISCVObservation(RISCV_TYPE type, RISCV_OBSERVATION_TYPE observation) implements Observation {

    @Override
    public int getValue() {
        return observation.value;
    }

    @Override
    public Type getType() {
        return type;
    }

    @Override
    public ObservationType getObservation() {
        return observation;
    }

    @Override
    public boolean matchExceptType(Observation observation) {
        return observation instanceof RISCVObservation && ((RISCVObservation) observation).observation == this.observation;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RISCVObservation that = (RISCVObservation) o;
        return type == that.type && observation == that.observation;
    }

    @Override
    public String toString() {
        return "\t\t" + type.toString() + ": " + observation.toString();
    }

    @Override
    public boolean isApplicable() {
        return switch (observation) {
            case FORMAT, OPCODE -> true;
            case FUNCT3 -> type.hasFunct3();
            case FUNCT7 -> type.hasFunct7();
            case RD, REG_RD, WAW_1, WAW_2, WAW_3, WAW_4, REG_RD_ZERO, REG_RD_LOG2 -> RISCVInstruction.hasRD(type);
            case RS1, REG_RS1, RAW_RS1_1, RAW_RS1_2, RAW_RS1_3, RAW_RS1_4, REG_RS1_ZERO, REG_RS1_LOG2 -> RISCVInstruction.hasRS1(type);
            case RS2, REG_RS2, RAW_RS2_1, RAW_RS2_2, RAW_RS2_3, RAW_RS2_4, REG_RS2_ZERO, REG_RS2_LOG2 -> RISCVInstruction.hasRS2(type);
            case IMM -> RISCVInstruction.hasIMM(type);
            case MEM_ADDR, IS_ALIGNED, IS_HALF_ALIGNED -> RISCVInstruction.isMEM(type);
            case MEM_R_DATA -> RISCVInstruction.isLOAD(type);
            case MEM_W_DATA -> RISCVInstruction.isSTORE(type);
            case IS_BRANCH, BRANCH_TAKEN, NEW_PC -> RISCVInstruction.isCONTROL(type);
        };
    }


}
