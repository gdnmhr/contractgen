package contractgen.generator.smt;

import contractgen.*;
import contractgen.util.Pair;

/**
 * A generator that uses SMT to perform a bounded model check.
 */
public class SimpleSMTGenerator extends Generator {

    /**
     * @param MARCH The microarchitecture to be used.
     */
    public SimpleSMTGenerator(contractgen.MARCH MARCH) {
        super(MARCH);
    }

    @Override
    public Contract generate() {
        MARCH.getISA().getTestCases().getIterator(0).forEachRemaining(testCase -> {
            MARCH.generateSources(testCase, null);
            String coverTrace = MARCH.runCover(150);
            int steps = MARCH.extractSteps(coverTrace);
            boolean pass = MARCH.run(steps);
            if (!pass) {
                TestResult ctx = MARCH.extractCTX(testCase);
                MARCH.getISA().getContract().add(ctx);
                MARCH.getISA().getContract().update(false);
            }
        });
        return MARCH.getISA().getContract();
    }
}
