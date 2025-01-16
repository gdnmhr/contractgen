package contractgen.riscv.isa.contract;

import contractgen.TestResult;
import contractgen.riscv.isa.RISCV_TYPE;
import contractgen.util.Pair;
import contractgen.Observation;
import contractgen.Type;

import java.util.Comparator;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * The result of the evaluation of a test case.
 */
public class RISCVTestResult extends TestResult {

    /**
     * @param possibilities            The observations that would distinguish the two executions.
     * @param adversaryDistinguishable Whether the adversary was able to distinguish the two executions.
     * @param index                    The index of the respective test case to allow to associate it with the result.
     */
    public RISCVTestResult(Set<RISCVObservation> possibilities, Set<Pair<RISCV_TYPE, RISCV_TYPE>> distinguishingInstructions, boolean adversaryDistinguishable, int index) {
        super(possibilities.stream().map(o -> (Observation) o).collect(Collectors.toSet()), distinguishingInstructions.stream().map(p -> new Pair<Type, Type>(p.left(), p.right())).collect(Collectors.toSet()), adversaryDistinguishable, index);
    }

    /**
     * @param allowed The set of allowed observation.
     * @return Whether any possible observation is allowed.
     */
    public boolean restrictObservations(Set<RISCV_OBSERVATION_TYPE> allowed) {
        this.observations = this.observations.stream().filter(obs -> allowed.contains(((RISCVObservation) obs).observation())).collect(Collectors.toSet());
        return !observations.isEmpty();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RISCVTestResult that = (RISCVTestResult) o;
        return Objects.equals(observations, that.observations);
    }

    @Override
    public int hashCode() {
        return Objects.hash(observations);
    }

    @Override
    public Observation getBestObservation() {
        return observations.stream().min(Comparator.comparingInt(Observation::getValue)).orElseThrow();
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("\t Observations: \n");
        observations.forEach(obs -> sb.append(obs.toString()).append("\n"));
        sb.append("\t Distinguishing instructions: \n");
        distinguishingInstructions.forEach(pair -> sb.append("\t\t").append(pair).append("\n"));
        sb.append("\t\t").append(isAdversaryDistinguishable());
        return sb.toString();
    }
}
