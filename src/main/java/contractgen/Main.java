package contractgen;

import contractgen.generator.iverilog.Falsifier;
import contractgen.generator.iverilog.ParallelIverilogGenerator;
import contractgen.riscv.cva6.CVA6;
import contractgen.riscv.ibex.IBEX;
import contractgen.riscv.isa.RISCV_SUBSET;
import contractgen.riscv.isa.RISCV_TYPE;
import contractgen.riscv.isa.contract.RISCVContract;
import contractgen.riscv.isa.contract.RISCVObservation;
import contractgen.riscv.isa.contract.RISCV_OBSERVATION_TYPE;
import contractgen.riscv.isa.extractor.BMCExtractor;
import contractgen.riscv.isa.tests.RISCVIterativeTests;
import contractgen.updater.ILPUpdater;
import contractgen.util.Pair;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.Set;

import java.util.concurrent.Callable;

@Command(name = "main", subcommands = {Synthesize.class, Analyze.class, Update.class, Evaluate.class, Falsify.class, PrintAtoms.class}, description = "Main application command.")
public class Main implements Callable<Integer> {
    public static void main(String[] args) {
        int exitCode = new CommandLine(new Main()).execute(args);
        System.exit(exitCode);
    }

    @Override
    public Integer call() throws Exception {
        // The default command when no subcommand is specified
        System.out.println("No command specified, defaulting to classic contactgen.");
        try {
            ContractGen.main(null);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
}

@Command(name = "synthesize", description = "Synthesize one contract.")
class Synthesize implements Callable<Integer> {
    // select the processor
    @Option(names = {"-p", "--processor"}, required = true, description = "The processor to use. Options: ${COMPLETION-CANDIDATES}")
    CONFIG.PROCESSOR processor;

    // select ISA
    @Option(names = {"-i", "--isa"}, required = true, description = "The ISA to use. Options: ${COMPLETION-CANDIDATES}", split = ",")
    Set<RISCV_SUBSET> isa;

    // select contract template
    @Option(names = {"-c", "--contract"}, required = true, description = "The contract template to use. Options: ${COMPLETION-CANDIDATES}", split = ",")
    Set<RISCV_OBSERVATION_TYPE.RISCV_OBSERVATION_TYPE_GROUP> template;

    // select number of test cases
    @Option(names = {"-n"}, required = true, description = "Number of test cases")
    int number;

    // select number of threads
    @Option(names = {"-t"}, required = true, description = "Number of threads")
    int threads;

    // select seed
    @Option(names = {"-s"}, required = true, description = "Seed")
    long seed;

    @Option(names = {"-o", "--output"}, required = true, description = "Output path (JSON)")
    File out;

    @Option(names = {"--txt"}, description = "Output path for txt-summary")
    File txt;

    @Override
    public Integer call() {
        TestCases tc = new RISCVIterativeTests(isa, RISCV_OBSERVATION_TYPE.getGroups(template), seed, threads, number);
        Generator generator = new ParallelIverilogGenerator(processor == CONFIG.PROCESSOR.IBEX ? new IBEX(new ILPUpdater(), tc, RISCV_OBSERVATION_TYPE.getGroups(template)) : new CVA6(new ILPUpdater(), tc, RISCV_OBSERVATION_TYPE.getGroups(template)), threads, false, null);
        
        long start = System.currentTimeMillis();
        Contract contract;
        try {
            contract = generator.generate();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        long finish = System.currentTimeMillis();
        long timeElapsed = finish - start;
        System.out.println("Generation time: " + timeElapsed);
        System.out.println(contract);
        if (txt != null) {
            try {
                Files.write(Path.of(txt.getPath()), contract.toString().getBytes());
            } catch (IOException e) {
            }
        }
        try (FileWriter writer = new FileWriter(out)) {
            contract.toJSON(writer);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
}

@Command(name = "analyze", description = "Analyze a counterexample from leave-bmc")
class Analyze implements Callable<Integer> {

    @Option(names = {"-f", "--file"}, required = true, description = "The trace vcd from bmc")
    File bmc_file;

    @Option(names = {"-o", "--output"}, required = true, description = "Output path (JSON)")
    File out;

    // select contract template
    @Option(names = {"-c", "--contract"}, required = true, description = "The contract template to use. Options: ${COMPLETION-CANDIDATES}", split = ",")
    Set<RISCV_OBSERVATION_TYPE.RISCV_OBSERVATION_TYPE_GROUP> template;

    @Override
    public Integer call() {
        Extractor extractor = new BMCExtractor(RISCV_OBSERVATION_TYPE.getGroups(template));
        Pair<TestResult, TestResult> res = extractor.extractResults(bmc_file.getPath(), true, 0);
        RISCVContract ctr = new RISCVContract(List.of(res.left(), res.right()), new ILPUpdater());
        System.out.println(ctr.toJSON());
        try (FileWriter writer = new FileWriter(out)) {
            ctr.toJSON(writer);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
}

@Command(name = "update", description = "Update a synthesized contract with one or more new results.")
class Update implements Callable<Integer> {

    @Option(names = {"-c", "--contract"}, required = true, description = "Old contract (JSON)")
    File old_ctr;

    @Option(names = {"-r", "--results"}, required = true,  description = "New results (JSON)")
    File new_results;

    @Option(names = {"-o", "--output"}, required = true,  description = "Output path (JSON)")
    File out;

    @Option(names = {"--txt"}, description = "Output path for txt-summary")
    File txt;

    @Override
    public Integer call() {
        try {
            RISCVContract contract = RISCVContract.fromJSON(new FileReader(old_ctr));
            System.out.println(contract);
            RISCVContract results = RISCVContract.fromJSON(new FileReader(new_results));
            for (TestResult res : results.getTestResults()) {
                contract.add(res);
            }
            contract.update(true);
            System.out.println(contract);
            contract.toJSON(new FileWriter(out));
            if (txt != null) {
                try (FileWriter writer = new FileWriter(txt)) {
                    writer.write(contract.toString());
                }
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return 0;
    }
}

@Command(name = "print_atoms", description = "Print all applicable atoms.")
class PrintAtoms implements Callable<Integer> {

    // select ISA
    @Option(names = {"-i", "--isa"}, required = true, description = "The ISA to use. Options: ${COMPLETION-CANDIDATES}", split = ",")
    Set<RISCV_SUBSET> isa;

    // select contract template
    @Option(names = {"-c", "--contract"}, required = true, description = "The contract template to use. Options: ${COMPLETION-CANDIDATES}")
    Set<RISCV_OBSERVATION_TYPE.RISCV_OBSERVATION_TYPE_GROUP> template;
    
    @Override
    public Integer call() {
        List<RISCV_TYPE> types = Arrays.stream(RISCV_TYPE.values()).filter(type -> isa.contains(type.getSubset())).toList();
        List<RISCV_OBSERVATION_TYPE> observations = RISCV_OBSERVATION_TYPE.getGroups(template).stream().toList();
        List<RISCVObservation> observationList = types.stream().map(type -> observations.stream().map(observation -> new RISCVObservation(type, observation)).toList()).flatMap(List::stream).toList();
        observationList = observationList.stream().filter(RISCVObservation::isApplicable).toList();
        observationList.forEach(System.out::println);
        return 0;
    }
}

@Command(name = "evaluate", description = "Evaluate a contract against a set of test cases.")
class Evaluate implements Callable<Integer> {

    @Option(names = {"-c", "--contract"}, required = true, description = "Verified contract (JSON)")
    File contract;

    @Option(names = {"-e", "--evalset"}, required = true,  description = "Evaluation set (JSON)")
    File evalset;

    @Option(names = {"-o", "--output"}, required = true,  description = "Output path (JSON)")
    File out;

    @Override
    public Integer call() {
        try {
            Files.createDirectories(out.toPath());
            ContractGen.basicStats(RISCVContract.fromJSON(new FileReader(contract)), RISCVContract.fromJSON(new FileReader(evalset)).getTestResults(), "Statistics", out.getPath() + "/stats", null);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return 0;
    }
}

@Command(name = "falsify", description = "Falsify a contract and output false negatives.")
class Falsify implements Callable<Integer> {

    @Option(names = {"-v", "--verified-contract"}, required = true, description = "Verified contract (JSON)")
    File contract;

    // select the processor
    @Option(names = {"-p", "--processor"}, required = true, description = "The processor to use. Options: ${COMPLETION-CANDIDATES}")
    CONFIG.PROCESSOR processor;

    // select ISA
    @Option(names = {"-i", "--isa"}, required = true, description = "The ISA to use. Options: ${COMPLETION-CANDIDATES}", split = ",")
    Set<RISCV_SUBSET> isa;

    // select contract template
    @Option(names = {"-c", "--contract"}, required = true, description = "The contract template to use. Options: ${COMPLETION-CANDIDATES}", split = ",")
    Set<RISCV_OBSERVATION_TYPE.RISCV_OBSERVATION_TYPE_GROUP> template;

    // select number of test cases
    @Option(names = {"-n"}, required = true, description = "Number of test cases")
    int number;

    // select number of threads
    @Option(names = {"-t"}, required = true, description = "Number of threads")
    int threads;

    // select seed
    @Option(names = {"-s"}, required = true, description = "Seed")
    long seed;

    @Option(names = {"-o", "--output"}, required = true, description = "Output path")
    Path out;

    @Override
    public Integer call() {
       try {
            RISCVContract ctr = RISCVContract.fromJSON(new FileReader(contract));
            ctr.update(true);
            out.toFile().mkdirs();
            Files.write(out.resolve("contract.txt"), ctr.toString().getBytes());
            TestCases tc = new RISCVIterativeTests(isa, RISCV_OBSERVATION_TYPE.getGroups(template), seed, threads, number);
            Generator generator = new Falsifier(processor == CONFIG.PROCESSOR.IBEX ? new IBEX(new ILPUpdater(), tc, RISCV_OBSERVATION_TYPE.getGroups(template)) : new CVA6(new ILPUpdater(), tc, RISCV_OBSERVATION_TYPE.getGroups(template)), threads, ctr, out);
            generator.generate();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return 0;
    }
}

