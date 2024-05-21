package contractgen;

import contractgen.riscv.isa.RISCV_TYPE;
import contractgen.riscv.isa.contract.RISCVContract;
import contractgen.riscv.isa.contract.RISCVObservation;
import contractgen.riscv.isa.contract.RISCV_OBSERVATION_TYPE;
import contractgen.riscv.isa.extractor.BMCExtractor;
import contractgen.updater.ILPUpdater;
import contractgen.util.Pair;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class Main implements Runnable {
    @Option(names = {"-s", "--synthesis"}, description = "Run synthesis")
    boolean synthesis;

    @Option(names = {"-a", "--analyze"}, description = "Analyze a counterexample from bmc")
    boolean analyze;

    @Option(names = {"-f", "--file"}, description = "The trace from bmc")
    File bmc_file;

    @Option(names = {"-p", "--print-atoms"}, description = "Print all atoms")
    boolean print_atoms;

    @Option(names = {"-u", "--update"}, description = "Update a synthesized contarct with new results")
    boolean update;

    @Option(names = {"-c", "--contract"}, description = "Old contract (JSON)")
    File old_ctr;

    @Option(names = {"-r", "--results"}, description = "New results (JSON)")
    File new_results;

    @Option(names = {"-o", "--output"}, description = "Output path")
    File out;


    @Override
    public void run() {
        if (synthesis) {
            try {
                ContractGen.main(null);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        } else if (analyze) {
            Extractor extractor = new BMCExtractor();
            Pair<TestResult, TestResult> res = extractor.extractResults(bmc_file.getPath(), true, 0);
            RISCVContract ctr = new RISCVContract(List.of(res.left(), res.right()), new ILPUpdater());
            System.out.println(ctr.toJSON());
            if (out != null) {
                try {
                    ctr.toJSON(new FileWriter(out));
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            }
        } else if (print_atoms) {
            List<RISCV_TYPE> types = Arrays.stream(RISCV_TYPE.values()).toList();
            List<RISCV_OBSERVATION_TYPE> observations = Arrays.stream(RISCV_OBSERVATION_TYPE.values()).toList();
            List<RISCVObservation> observationList = types.stream().map(type -> observations.stream().map(observation -> new RISCVObservation(type, observation)).toList()).flatMap(List::stream).toList();
            observationList = observationList.stream().filter(RISCVObservation::isApplicable).toList();
            observationList.forEach(System.out::println);
        } else if (update) {
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
            } catch (IOException e) {
                throw new RuntimeException(e);
            }

        }
    }

    public static void main(String... args) {
        new CommandLine(new Main()).execute(args);
    }
}
