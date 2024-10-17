package contractgen.simple.isa.contract;

import contractgen.Contract;
import contractgen.Updater;
import contractgen.simple.isa.SIMPLE_TYPE;

import java.util.*;
import java.util.stream.Collectors;

/**
 * A contract for the simple ISA.
 */
public class SimpleContract extends Contract {

    /**
     * @param updater The updater to be used.
     */
    public SimpleContract(Updater updater) {
        super(updater);
    }

    public String printContract() {

        Map<SIMPLE_TYPE, List<SimpleObservation>> observations_per_type =
                getCurrentContract().stream().map(obs -> (SimpleObservation) obs).collect(Collectors.groupingBy(SimpleObservation::type));

        StringBuilder sb = new StringBuilder();

        observations_per_type.forEach((type, observations) -> {
            sb.append(type.generateContract("1"));
            for (SIMPLE_OBSERVATION_TYPE observation_type : SIMPLE_OBSERVATION_TYPE.values()) {
                sb.append(observation_type.generateObservation("1", observations.stream().anyMatch(o -> o.observation() == observation_type)));
            }
            sb.append("end\n");
        });

        observations_per_type.forEach((type, observations) -> {
            sb.append(type.generateContract("2"));
            for (SIMPLE_OBSERVATION_TYPE observation_type : SIMPLE_OBSERVATION_TYPE.values()) {
                sb.append(observation_type.generateObservation("2", observations.stream().anyMatch(o -> o.observation() == observation_type)));
            }
            sb.append("end\n");
        });

        return sb.toString();
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder("Current counterexamples: \n");
        getTestResults().forEach(ctx -> sb.append(ctx.toString()).append("\n"));
        sb.append("Inferred contract: \n");
        getCurrentContract().forEach(obs -> sb.append(obs.toString()).append("\n"));
        return sb.toString();
    }
}
