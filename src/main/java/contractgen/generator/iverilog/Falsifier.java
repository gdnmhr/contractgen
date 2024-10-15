package contractgen.generator.iverilog;

import java.io.IOException;

import contractgen.Contract;
import contractgen.Generator;
import contractgen.MARCH;
import contractgen.SIMULATION_RESULT;
import contractgen.TestResult;
import contractgen.riscv.isa.contract.RISCVContract;
import contractgen.util.Pair;

import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

import java.nio.file.Path;
import java.nio.file.Files;


public class Falsifier extends Generator {

    /**
     * The number of threads to be used.
     */
    private final int COUNT;

    private final RISCVContract ctr;

    private final Path outdir;

    public Falsifier(contractgen.MARCH MARCH, int threads, RISCVContract ctr, Path outdir) {
        super(MARCH);
        this.COUNT = threads;
        this.outdir = outdir;
        this.ctr = ctr;
    }

    @Override
    public Contract generate() throws IOException {
        System.out.println("Evaluating " + MARCH.getISA().getTestCases().getTotalNumber() + " test cases.");
        AtomicInteger atomic_i = new AtomicInteger(0);
        MARCH.compile();
        outdir.toFile().mkdirs();
        List<Thread> runners = new ArrayList<>();
        for (int i = 0; i < COUNT; i++) {
            runners.add(new Thread(new Runner(MARCH, i + 1, atomic_i, ctr, outdir.resolve(Integer.toString(i + 1))), "Runner_" + (i + 1)));
        }
        runners.forEach(Thread::start);
        runners.forEach(t -> {
            try {
                t.join();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        });
        return null;
    }
    
    /**
     * A contractgen runner.
     */
    public static class Runner implements Runnable {

        /**
         * The microarchitecture.
         */
        private final MARCH MARCH;
        /**
         * The id of the runner.
         */
        private final int id;
        /**
         * A synchronized counter to show a progress.
         */
        private final AtomicInteger atomic_i;
        /**
         * The contract to falsify.
         */
        private final RISCVContract ctr;
        /**
         * A path to copy false negatives to.
         */
        private final Path outdir;

        /**
         * @param MARCH    The microarchitecture.
         * @param id       The id of the runner.
         * @param atomic_i A synchronized counter to show a progress.
         * @param stats    A path to copy false negatives to.
         */
        Runner(MARCH MARCH, int id, AtomicInteger atomic_i, RISCVContract ctr, Path outdir) {
            this.MARCH = MARCH;
            this.id = id;
            this.atomic_i = atomic_i;
            this.ctr = ctr;
            this.outdir = outdir;
        }

        @Override
        public void run() {
            outdir.toFile().mkdirs();
            MARCH.getISA().getTestCases().getIterator(id - 1).forEachRemaining(testCase -> {
                try {
                    MARCH.writeTestCase(id, testCase);
                    SIMULATION_RESULT pass = MARCH.simulate(id);
                    if (pass == SIMULATION_RESULT.FAIL) {
                        Pair<TestResult, TestResult> ctx = MARCH.extractDifferences(id, testCase.getIndex());
                        if (!ctr.covers(ctx.left()) || !ctr.covers(ctx.right())) {
                            System.out.println("Runner[" + id + "] False negative found for test case " + testCase.getIndex() + "!");
                            // copy files to output folder
                            outdir.resolve(Integer.toString(testCase.getIndex())).toFile().mkdirs();
                            testCase.getProgram1().printInit(outdir.resolve(testCase.getIndex() + "/init_1.dat").toString());
                            testCase.getProgram1().printInstr(outdir.resolve(testCase.getIndex() + "/memory_1.dat").toString());
                            Files.write(outdir.resolve(testCase.getIndex() + "/program_1.txt"), testCase.getProgram1().toString().getBytes());
                            testCase.getProgram2().printInit(outdir.resolve(testCase.getIndex() + "/init_2.dat").toString());
                            testCase.getProgram2().printInstr(outdir.resolve(testCase.getIndex() + "/memory_2.dat").toString());
                            Files.write(outdir.resolve(testCase.getIndex() + "/program_2.txt"), testCase.getProgram2().toString().getBytes());
                            Files.copy(Path.of(MARCH.getSimulationTracePath(id)), outdir.resolve(testCase.getIndex() + "/trace.vcd"));
                            {
                                final StringBuilder sb = new StringBuilder();
                                ctx.left().getPossibleObservations().forEach(o -> sb.append(o.toString()).append("\n"));
                                Files.write(outdir.resolve(testCase.getIndex() + "/obs1.txt"), sb.toString().getBytes());
                            }
                            {
                                final StringBuilder sb = new StringBuilder();
                                ctx.right().getPossibleObservations().forEach(o -> sb.append(o.toString()).append("\n"));
                                Files.write(outdir.resolve(testCase.getIndex() + "/obs2.txt"), sb.toString().getBytes());
                            }
                        }
                    }

                    int i = atomic_i.incrementAndGet();
                    System.out.printf("Current progress: %d of %d.\r", i, MARCH.getISA().getTestCases().getTotalNumber());
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }

            });
        }

    }
}
