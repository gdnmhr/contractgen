package contractgen;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import contractgen.util.Pair;

import java.io.FileWriter;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Abstract contract.
 */
public abstract class Contract {

    /**
     * All possible contract atoms.
     */
    protected final Set<Observation> ALL_ATOMS;

    /**
     * The results of all testcases that have been evaluated yet.
     */
    private final List<TestResult> testResults = new ArrayList<>();
    /**
     * The latest synthesized contract
     */
    private Set<Observation> current_contract = new HashSet<>();


    /**
     * The updater that is used to compute the contract from the collected test results.
     */
    protected final Updater updater;

    /**
     * @param updater The updater to infer a contract from the test results
     */
    protected Contract(Set<Observation> allAtoms, Updater updater) {
        this.ALL_ATOMS = allAtoms;
        this.updater = updater;
    }

    /**
     * @param initialResults Initial test results from previous runs
     * @param updater        The updater to infer a contract from the test results
     */
    protected Contract(Set<Observation> allAtoms, List<TestResult> initialResults, Updater updater) {
        this.ALL_ATOMS = allAtoms;
        this.updater = updater;
        this.testResults.addAll(initialResults);
        this.update(true);
    }

    /**
     * Computes a contract candidate that covers all collected test results.
     *
     * @param force Whether the contract should be updated even if the current contract covers all test results.
     * @return Whether the contract has changed.
     */
    public boolean update(boolean force) {
        if (!force && coversAll()) return false;
        Set<Observation> old = current_contract;
        current_contract = updater.update(ALL_ATOMS, testResults, old);
        return !Objects.equals(old, current_contract);
    }

    /**
     * @return Whether the current computed contract covers all collected test results.
     */
    public boolean coversAll() {
        return coversAll(testResults, current_contract);
    }

    /**
     * @param contract The contract to be used.
     * @return Whether the given contract covers all collected test results.
     */
    public boolean coversAll(Set<Observation> contract) {
        return coversAll(testResults, contract);
    }

    /**
     * @param testResults The test results to be used.
     * @param contract    The contract to be used.
     * @return Whether the given contract covers the given test results.
     */
    public static boolean coversAll(List<TestResult> testResults, Set<Observation> contract) {
        return testResults.stream().filter(TestResult::isAdversaryDistinguishable).filter(ctx -> covers(contract, ctx)).collect(Collectors.toSet()).containsAll(testResults);
    }

    /**
     * @param res The test result to be checked.
     * @return Whether the current computed contract covers the given result.
     */
    public boolean covers(TestResult res) {
        return covers(current_contract, res);
    }

    /**
     * @param contract The contract to be used.
     * @param res      The test result to be checked.
     * @return Whether the given contract covers the given result.
     */
    public static boolean covers(Set<Observation> contract, TestResult res) {
        for (Pair<Type, Type> distinguishingTypes: res.getDistinguishingInstructions()) {
            Set<Observation> obs_left = contract.stream().filter(o -> o.getType().equals(distinguishingTypes.left())).collect(Collectors.toSet());
            Set<Observation> obs_right = contract.stream().filter(o -> o.getType().equals(distinguishingTypes.right())).collect(Collectors.toSet());
            // if the number of observations for left and right type is different, the contract does always cover this
            if (obs_left.size() != obs_right.size()) {
                return true;
            }
            // check if there is a matching observation for left and right type, size is the same, so we can do it either way

            if (!obs_left.stream().allMatch(ol -> obs_right.stream().anyMatch(or -> ol.matchExceptType(or)))) {
                return true;
            }
        }
        return contract.stream().anyMatch(obs -> res.getDistinguishingObservations().contains(obs));
    }

    /**
     * @param contract The contract to be used.
     * @param res      The test result to be checked.
     * @return Whether the given contract covers the given result.
     */
    public static Pair<Set<Observation>, Set<Pair<Type, Type>>> whyCovers(Set<Observation> contract, TestResult res) {
        Set<Pair<Type, Type>> distinguishingTypes = new HashSet<>();
        for (Pair<Type, Type> distinguishingType : res.getDistinguishingInstructions()) {
            Set<Observation> obs_left = contract.stream().filter(o -> o.getType().equals(distinguishingType.left())).collect(Collectors.toSet());
            Set<Observation> obs_right = contract.stream().filter(o -> o.getType().equals(distinguishingType.right())).collect(Collectors.toSet());
            // if the number of observations for left and right type is different, the contract does always cover this
            if (obs_left.size() != obs_right.size()) {
                distinguishingTypes.add(distinguishingType);
            }
            // check if there is a matching observation for left and right type, size is the same, so we can do it either way
            if (!obs_left.stream().allMatch(ol -> obs_right.stream().anyMatch(or -> ol.matchExceptType(or)))) {
                distinguishingTypes.add(distinguishingType);
            }
        }
        Set<Observation> distinguishingAtoms = contract.stream().filter(obs -> res.getDistinguishingObservations().contains(obs)).collect(Collectors.toSet());
        return new Pair<Set<Observation>,Set<Pair<Type,Type>>>(distinguishingAtoms, distinguishingTypes);
    }

    /**
     * @param res The test result to be checked.
     * @return Whether the given contract covers the given result.
     */
    public Pair<Set<Observation>, Set<Pair<Type, Type>>> whyCovers(TestResult res) {
        return whyCovers(this.current_contract, res);
    }

    /**
     * Adds a new test result to the contract.
     *
     * @param res The test result to be added.
     */
    public void add(TestResult res) {
        testResults.add(res);
    }

    /**
     * Prints the contract in a format to be used in Verilog modules.
     *
     * @return The current contract.
     */
    public abstract String printContract();

    /**
     * @return The number of elements in the current computed contract.
     */
    public int getSize() {
        return current_contract.size();
    }

    /**
     * Sorts the test results by their respective index.
     * Can be used to obtain reproducible results after generating the contract with multiple threads.
     */
    public void sort() {
        this.testResults.sort(Comparator.comparingInt(TestResult::getIndex));
    }

    /**
     * @return Currently collected test results.
     */
    public List<TestResult> getTestResults() {
        return testResults;
    }

    /**
     * @return The current computed contract.
     */
    public Set<Observation> getCurrentContract() {
        return current_contract;
    }


    /**
     * @return The number of test results collected so far
     */
    public int getTotal() {
        return getTestResults().size();
    }

    /**
     * @return The number of atoms in the latest contract
     */
    public int getContractSize() {
        return getCurrentContract().size();
    }

    /**
     * @return The number of distinguishable test results
     */
    public int getDistinguishableCount() {
        return (int) getTestResults().stream().filter(TestResult::isAdversaryDistinguishable).count();
    }

    /**
     * @return The number of indistinguishable test results
     */
    public int getIndistinguishableCount() {
        return (int) getTestResults().stream().filter(TestResult::isAdversaryIndistinguishable).count();
    }

    /**
     * @return The number of false positives according to the latest contract
     */
    public int getFalsePositiveCount() {
        return (int) getTestResults().stream().filter(TestResult::isAdversaryIndistinguishable).filter(this::covers).count();
    }

    /**
     * @return A string containing useful stats about the contract
     */
    public String getTotalStats() {
        StringBuilder sb = new StringBuilder();
        sb.append("TestResults: ").append("\n");
        sb.append("\tTotal: ").append(getTotal()).append("\n");
        sb.append("\tDistinguishable: ").append(getDistinguishableCount()).append("\n");
        sb.append("\tIndistinguishable: ").append(getIndistinguishableCount()).append("\n");
        return sb.toString();
    }

    /**
     * @return A string containing useful stats about the latest inferred contract
     */
    public String getContractStats() {
        StringBuilder sb = new StringBuilder();
        sb.append("Contract: ").append("\n");
        sb.append("\tSize: ").append(getContractSize()).append("\n");
        sb.append("\tFalse Positives: ").append(getFalsePositiveCount()).append("\n");
        return sb.toString();
    }

    @Override
    public abstract String toString();

    /**
     * @return A string with the json representation of the instance.
     */
    public String toJSON() {
        GsonBuilder builder = new GsonBuilder();
        builder.setPrettyPrinting();
        Gson gson = builder.create();
        return gson.toJson(this);
    }

    /**
     * @param file The file to write to
     * @throws IOException On filesystem errors.
     */
    public void toJSON(FileWriter file) throws IOException {
        GsonBuilder builder = new GsonBuilder();
        builder.setPrettyPrinting();
        Gson gson = builder.create();
        gson.toJson(this, file);
        file.flush();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Contract contract = (Contract) o;
        return Objects.equals(testResults, contract.testResults) && Objects.equals(updater, contract.updater);
    }

    @Override
    public int hashCode() {
        return Objects.hash(testResults, updater);
    }
}
