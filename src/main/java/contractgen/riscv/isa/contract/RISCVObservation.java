package contractgen.riscv.isa.contract;

import contractgen.Observation;
import contractgen.riscv.isa.RISCV_TYPE;

/**
 * An onservation for the RISC-V ISA.
 *
 * @param type          The type of instruction this observation should be associated to.
 * @param observation   The observation type.
 */
public record RISCVObservation(RISCV_TYPE type, RISCV_OBSERVATION_TYPE observation) implements Observation {

    @Override
    public int getValue() {
        return observation.value;
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


}
