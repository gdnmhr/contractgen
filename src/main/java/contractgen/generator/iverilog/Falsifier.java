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
        AtomicInteger error = new AtomicInteger(0);
        AtomicInteger fail = new AtomicInteger(0);
        MARCH.compile();
        outdir.toFile().mkdirs();
        Path errorPath = outdir.resolve("error");
        errorPath.toFile().mkdirs();
        Path falseNegativesPath = outdir.resolve("falseNegatives");
        falseNegativesPath.toFile().mkdirs();
        List<Thread> runners = new ArrayList<>();
        for (int i = 0; i < COUNT; i++) {
            runners.add(new Thread(new Runner(MARCH, i + 1, atomic_i, error, fail, ctr, errorPath, falseNegativesPath), "Runner_" + (i + 1)));
        }
        runners.forEach(Thread::start);
        runners.forEach(t -> {
            try {
                t.join();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        });
        System.out.println("Total number of errors: " + error.get());
        System.out.println("Total number of false negatives: " + fail.get());
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
         * A synchronized counter for simulation errors.
         */
        private final AtomicInteger error;
        /**
         * A synchronized counter for false negatives.
         */
        private final AtomicInteger fail;
        /**
         * The contract to falsify.
         */
        private final RISCVContract ctr;
        /**
         * A path to copy simulation errors to.
         */
        private final Path errorPath;
        /**
         * A path to copy false negatives to.
         */
        private final Path falseNegativesPath;

        /**
         * @param MARCH    The microarchitecture.
         * @param id       The id of the runner.
         * @param atomic_i A synchronized counter to show a progress.
         * @param stats    A path to copy false negatives to.
         */
        Runner(MARCH MARCH, int id, AtomicInteger atomic_i, AtomicInteger error, AtomicInteger fail, RISCVContract ctr, Path errorPath, Path falseNegativesPath) {
            this.MARCH = MARCH;
            this.id = id;
            this.atomic_i = atomic_i;
            this.error = error;
            this.fail = fail;
            this.ctr = ctr;
            this.errorPath = errorPath;
            this.falseNegativesPath = falseNegativesPath;
        }

        @Override
        public void run() {
            MARCH.getISA().getTestCases().getIterator(id - 1).forEachRemaining(testCase -> {
                try {
                    MARCH.writeTestCase(id, testCase);
                    SIMULATION_RESULT pass = MARCH.simulate(id);
                    if (pass == SIMULATION_RESULT.ERROR) {
                        int errno = error.incrementAndGet();
                        Path path = errorPath.resolve(Integer.toString(errno));
                        path.toFile().mkdirs();
                        System.out.println("Runner[" + id + "] Simulation error for test case " + testCase.getIndex() + "!");
                        testCase.getProgram1().printInit(path.resolve("init_1.dat").toString());
                        testCase.getProgram1().printInstr(path.resolve("memory_1.dat").toString());
                        Files.write(path.resolve("program_1.txt"), testCase.getProgram1().toString().getBytes());
                        testCase.getProgram2().printInit(path.resolve("init_2.dat").toString());
                        testCase.getProgram2().printInstr(path.resolve("memory_2.dat").toString());
                        Files.write(path.resolve("program_2.txt"), testCase.getProgram2().toString().getBytes());
                        Files.copy(Path.of(MARCH.getSimulationTracePath(id)), path.resolve("trace.vcd"), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                    } else
                    if (pass == SIMULATION_RESULT.FAIL) {
                        TestResult ctx = MARCH.extractDifferences(id, testCase.getIndex());
                        if (!ctr.covers(ctx)) {
                            System.out.println(ctr.getCurrentContract());
                            System.out.println(ctx.getDistinguishingObservations());
                            int failno = fail.incrementAndGet();
                            Path path = falseNegativesPath.resolve(Integer.toString(failno));
                            path.toFile().mkdirs();
                            System.out.println("Runner[" + id + "] False negative found for test case " + testCase.getIndex() + "!");
                            // copy files to output folder
                            testCase.getProgram1().printInit(path.resolve("init_1.dat").toString());
                            testCase.getProgram1().printInstr(path.resolve("memory_1.dat").toString());
                            Files.write(path.resolve("program_1.txt"), testCase.getProgram1().toString().getBytes());
                            testCase.getProgram2().printInit(path.resolve("init_2.dat").toString());
                            testCase.getProgram2().printInstr(path.resolve("memory_2.dat").toString());
                            Files.write(path.resolve("program_2.txt"), testCase.getProgram2().toString().getBytes());
                            Files.copy(Path.of(MARCH.getSimulationTracePath(id)), path.resolve("trace.vcd"), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                            {
                                final StringBuilder sb = new StringBuilder();
                                ctx.getDistinguishingObservations().forEach(o -> sb.append(o.toString()).append("\n"));
                                Files.write(path.resolve("dist-obs.txt"), sb.toString().getBytes());
                            }
                            {
                                final StringBuilder sb = new StringBuilder();
                                ctx.getDistinguishingInstructions().forEach(p -> sb.append("(").append(p.left().toString()).append(",").append(p.right().toString()).append(")\n"));
                                Files.write(path.resolve("dist-insn.txt"), sb.toString().getBytes());
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
