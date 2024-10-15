package contractgen.riscv.cva6;

import contractgen.*;
import contractgen.riscv.isa.RISCV;
import contractgen.riscv.isa.contract.RISCV_OBSERVATION_TYPE;
import contractgen.riscv.isa.extractor.RVFIExtractor;
import contractgen.util.Pair;
import contractgen.util.StringUtils;
import contractgen.util.vcd.VcdFile;

import java.util.Set;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import static contractgen.util.FileUtils.copyFileOrFolder;
import static contractgen.util.FileUtils.replaceString;
import static contractgen.util.ScriptUtils.runScript;
import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;

/**
 * The CVA6 microarchitecture.
 */
public class CVA6 extends MARCH {


    /**
     * The path where to find the template.
     */
    private static final String TEMPLATE_PATH = "/home/yosys/resources/cva6/";
    /**
     * The path where to store the instantiated template.
     */
    protected String BASE_PATH = "/home/yosys/output/cva6/generated/";
    /**
     * The path where the compiled module is to be stored.
     */
    protected String COMPILATION_PATH = "/home/yosys/output/cva6/compiled/";
    /**
     * The path where simulation takes place.
     */
    protected String SIMULATION_PATH = "/home/yosys/output/cva6/simulation/";

    /**
     * @param updater   The updater to be used to update the contract.
     * @param testCases The test cases to be used for generation or evaluation.
     */
    public CVA6(Updater updater, TestCases testCases, Set<RISCV_OBSERVATION_TYPE> allowed_observations) {
        super(new RISCV(updater, testCases), new RVFIExtractor(allowed_observations));
    }

    @Override
    public void generateSources(TestCase testCase, Integer max_count) {
        throw new UnsupportedOperationException("Not implemented");
    }

    @Override
    public String runCover(int steps) {

        throw new UnsupportedOperationException("Not implemented");
    }

    @Override
    public int extractSteps(String coverTrace) {
        throw new UnsupportedOperationException("Not implemented");
    }

    @Override
    public boolean run(int steps) {
        throw new UnsupportedOperationException("Not implemented");
    }

    @Override
    public Pair<TestResult, TestResult> extractCTX(TestCase testCase) {
        return extractCTX(SIMULATION_PATH, testCase);
    }

    @Override
    public Pair<TestResult, TestResult> extractCTX(int id, TestCase testCase) {
        return extractCTX(SIMULATION_PATH + id + "/", testCase);
    }

    /**
     * @param PATH     The path of the simulation.
     * @param testCase The simulated testcase.
     * @return A set of two test results
     */
    private Pair<TestResult, TestResult> extractCTX(String PATH, TestCase testCase) {
        VcdFile vcd;
        try {
            vcd = new VcdFile(Files.readString(Path.of(PATH + "sim.vcd")));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        int failTime = vcd.getTop().getChild("atk").getWire("atk_equiv_o").getLastChangeTime();
        int fetch_1 = Integer.parseInt(vcd.getTop().getChild("control").getWire("fetch_1_count").getValueAt(failTime), 2);
        int fetch_2 = Integer.parseInt(vcd.getTop().getChild("control").getWire("fetch_2_count").getValueAt(failTime), 2);
        int retire = Integer.parseInt(vcd.getTop().getChild("control").getWire("retire_count").getValueAt(failTime), 2);
        int currentGuess = Integer.max(fetch_1, fetch_2);
        while (currentGuess >= retire && simulateSteps(PATH, currentGuess) == SIMULATION_RESULT.FAIL) {
            currentGuess--;
        }
        simulateSteps(PATH, currentGuess + 1);
        return extractDifferences(PATH, true, testCase.getIndex());
    }

    @Override
    public Pair<TestResult, TestResult> extractDifferences(int index) {
        return extractDifferences(SIMULATION_PATH, false, index);
    }

    @Override
    public Pair<TestResult, TestResult> extractDifferences(int id, int index) {
        return extractDifferences(SIMULATION_PATH + id + "/", false, index);
    }

    /**
     * @param PATH                     The path of the vcd file.
     * @param adversaryDistinguishable whether the simulation was distinguishable by an adversary.
     * @param index                    the index of the testcase for further reference.
     * @return The differences that would allow a contract to distinguish the two executions.
     */
    private Pair<TestResult, TestResult> extractDifferences(String PATH, boolean adversaryDistinguishable, int index) {
        return getExtractor().extractResults(PATH, adversaryDistinguishable, index);
    }

    @Override
    public void compile() {
        try {
            copyFileOrFolder(Path.of(TEMPLATE_PATH).toFile(), Path.of(BASE_PATH).toFile(), REPLACE_EXISTING);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        // contract
        synchronized (getISA().getContract()) {
            replaceString(BASE_PATH + "verif/ctr.sv", "/* CONTRACT */", getISA().getContract().printContract());
        }
        // Enable this section to regenerate the CVA6 Verilog file, disabled for performance reasons, using precompiled cva6.v instead
        /*
        runScript("/bin/bash " + BASE_PATH + "generate-verilog.sh " + BASE_PATH + " " + BASE_PATH + "temp", false, 100000);
        try {
            copyFileOrFolder(Path.of(BASE_PATH + "temp/cva6.v").toFile(), Path.of(BASE_PATH + "cva6.v").toFile(), REPLACE_EXISTING);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
         */
        runScript("/bin/bash " + BASE_PATH + "compile.sh " + BASE_PATH + " " + COMPILATION_PATH, false, 240);
        System.out.println("Compilation finished.");
    }

    @Override
    public void writeTestCase(TestCase testCase) {
        writeTestCase(SIMULATION_PATH, testCase);
    }

    @Override
    public void writeTestCase(int id, TestCase testCase) {
        writeTestCase(SIMULATION_PATH + id + "/", testCase);
    }

    /**
     * @param PATH     the path to which the test case should be written.
     * @param testCase The test case to be written to disk.
     */
    private void writeTestCase(String PATH, TestCase testCase) {
        try {
            copyFileOrFolder(Path.of(COMPILATION_PATH + "ariane").toFile(), Path.of(PATH + "ariane").toFile(), REPLACE_EXISTING);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        testCase.getProgram1().printInit(PATH + "init_1.dat");
        testCase.getProgram1().printInstr(PATH + "memory_1.dat");
        testCase.getProgram2().printInit(PATH + "init_2.dat");
        testCase.getProgram2().printInstr(PATH + "memory_2.dat");
        try {
            Files.write(Paths.get(PATH + "count.dat"), StringUtils.toHexEncoding((long) (testCase.getMaxInstructionCount() + 131)).getBytes());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public SIMULATION_RESULT simulate() {
        return simulate(SIMULATION_PATH);
    }

    @Override
    public SIMULATION_RESULT simulate(int id) {
        return simulate(SIMULATION_PATH + id + "/");
    }

    /**
     * @param PATH The simulation path.
     * @return The result of the simulation.
     */
    private SIMULATION_RESULT simulate(String PATH) {
        String output = runScript(PATH + "ariane", true, 10000);
        if (output == null) return SIMULATION_RESULT.UNKNOWN;
        if (output.contains("FAIL")) return SIMULATION_RESULT.FAIL;
        if (output.contains("FALSE_POSITIVE")) return SIMULATION_RESULT.FALSE_POSITIVE;
        if (output.contains("SUCCESS")) return SIMULATION_RESULT.SUCCESS;
        if (output.contains("TIMEOUT")) return SIMULATION_RESULT.TIMEOUT;
        return SIMULATION_RESULT.UNKNOWN;
    }

    /**
     * @param PATH  The simulation path.
     * @param steps The number of steps to be simulated.
     * @return The result of the simulation.
     */
    private SIMULATION_RESULT simulateSteps(String PATH, int steps) {
        try {
            Files.write(Paths.get(PATH + "count.dat"), StringUtils.toHexEncoding((long) steps).getBytes());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return simulate(PATH);
    }

    @Override
    public String getName() {
        return "cva6";
    }

    public String getSimulationTracePath(int id) {
        return SIMULATION_PATH + id + "/" + "sim.vcd";
    }
}
