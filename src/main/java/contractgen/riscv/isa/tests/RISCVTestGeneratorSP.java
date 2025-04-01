package contractgen.riscv.isa.tests;

import contractgen.TestCase;
import contractgen.riscv.isa.*;
import contractgen.riscv.isa.contract.RISCVTestResult;
import contractgen.riscv.isa.contract.RISCVObservation;
import contractgen.riscv.isa.contract.RISCV_OBSERVATION_TYPE;

import java.util.*;
import java.util.stream.Stream;

/**
 * A generator for RISC-V test cases.
 */
public class RISCVTestGeneratorSP implements RISCVTestGenearatorInterface {
    /**
     * The number of registers in the microarchitecture.
     */
    private static final int NUMBER_REGISTERS = 32;
    /**
     * The maximum value of a register.
     */
    @SuppressWarnings("unused")
    private static final long MAX_REG = 4294967296L;
    /**
     * The maximum value of a I-type immediate.
     */
    private static final int MAX_IMM_I = 4096; // 2^12
    /**
     * The maximum value of a B-type immediate.
     */
    private static final long MAX_IMM_B = 8192; // 2^13
    /**
     * The maximum value of a U-type immediate.
     */
    private static final long MAX_IMM_U = 4294967296L; // 2^32
    /**
     * The maximum value of a J-type immediate.
     */
    private static final long MAX_IMM_J = 2097152; // 2^21

    /**
     * A pseudo-random number generator.
     */
    private final Random r;
    /**
     * The number of repetitions to be generated.
     */
    private final int repetitions;
    /**
     * The instruction types to be considered.
     */
    private final List<RISCV_TYPE> types;
    /**
     * The allowed observations.
     */
    private final List<RISCV_OBSERVATION_TYPE> allowed_observations;

    /**
     * @param subsets     the allowed ISA subsets.
     * @param seed        the random seed.
     * @param repetitions the number of repetitions to be generated.
     */
    RISCVTestGeneratorSP(Set<RISCV_SUBSET> subsets, long seed, int repetitions) {
        r = new Random(seed);
        this.repetitions = repetitions;
        this.types = Arrays.stream(RISCV_TYPE.values()).filter(t -> subsets.contains(t.getSubset())).toList();
        this.allowed_observations = Arrays.stream(RISCV_OBSERVATION_TYPE.values()).toList();
    }

    /**
     * @param subsets              the allowed ISA subsets.
     * @param allowed_observations the allowed observations.
     * @param seed                 the random seed.
     * @param repetitions          the number of repetitions to be generated.
     */
    RISCVTestGeneratorSP(Set<RISCV_SUBSET> subsets, Set<RISCV_OBSERVATION_TYPE> allowed_observations, long seed, int repetitions) {
        r = new Random(seed);
        this.repetitions = repetitions;
        this.types = Arrays.stream(RISCV_TYPE.values()).filter(t -> subsets.contains(t.getSubset())).toList();
        this.allowed_observations = allowed_observations.stream().toList();
    }

    /**
     * Generates a list of test cases by generating a random initial valuation for each register,
     * a random instruction of a certain type and suffix to be appended to the program.
     *
     * @return The list of test cases.
     */
    public List<TestCase> generate() {
        List<TestCase> cases = new ArrayList<>();
        for (int i = 0; i < repetitions; i++) {
            cases.addAll(nextRepetition(cases.size()));
            //if (i % 3 == 0)
            //    cases.add(new RISCVTestCase(new RISCVProgram(randomRegisters(), randomSequence(r.nextInt(5, 50))), new RISCVProgram(randomRegisters(), randomSequence(r.nextInt(5, 50))), 50, index++));
        }
        return cases;

    }

    public static <T> List<T> insertAtSecondToLast(List<T> list, T element) {
        // Create a new modifiable list
        List<T> modifiableList = new ArrayList<>(list);

        // Insert the element at the second-to-last position
        modifiableList.add(modifiableList.size() - 1, element);

        // Return an immutable copy of the new list
        return Collections.unmodifiableList(modifiableList);
    }

    /**
     * @param index starting index
     * @return a list of test cases.
     */
    public List<TestCase> nextRepetition(int index) {
        List<TestCase> cases = new ArrayList<>();
        for (RISCV_TYPE type : types) {
            Map<Integer, Integer> registers_1 = randomRegisters();
            Map<Integer, Integer> registers_2 = randomRegisters();
            List<RISCVInstruction> suffix = randomSequence(r.nextInt(5, 25));
            RISCVInstruction instruction = randomInstructionFromType(type);
            for (RISCV_OBSERVATION_TYPE observation : allowed_observations) {
                cases.add(new RISCVTestCase(
                    new RISCVProgram(registers_1, Stream.concat(List.of(instruction).stream(), suffix.stream()).toList()),
                    new RISCVProgram(registers_2, Stream.concat(List.of(instruction).stream(), suffix.stream()).toList()),
                    suffix.size() + 1, new RISCVTestResult(Set.of(new RISCVObservation(type, observation)), Set.of(), true, index), index++));
            }
        }
        return cases;
    }


    /**
     * @return A random initialization for each register.
     */
    private Map<Integer, Integer> randomRegisters() {
        Map<Integer, Integer> result = new HashMap<>(NUMBER_REGISTERS - 1);
        for (int i = 1; i < NUMBER_REGISTERS; i++) {
            if (r.nextBoolean()) {
                result.put(i, r.nextInt(MAX_IMM_I));
            } else {
                if (r.nextBoolean()) {
                    result.put(i, null);
                }
            }
        }
        return result;
    }

    /**
     * @param size The length of the sequence
     * @return A sequence of given length of random instructions.
     */
    private List<RISCVInstruction> randomSequence(int size) {
        List<RISCVInstruction> result = new ArrayList<>(size);
        for (int i = 0; i < size; i++) {
            RISCV_TYPE type = types.get(r.nextInt(types.size() - 1));
            RISCVInstruction instruction = randomInstructionFromType(type);
            // ensure jalr are always aligned
            if (type == RISCV_TYPE.JALR) {
                result.add(RISCVInstruction.ANDI(instruction.rs1(), instruction.rs1(), MAX_IMM_I - 4));
                i++;
            }
            result.add(instruction);
        }
        return result;
    }

    /**
     * @param type the type of the desired instruction
     * @return a random instance of an instruction of the given type.
     */
    private RISCVInstruction randomInstructionFromType(RISCV_TYPE type) {
        return switch (type.getFormat()) {
            case RTYPE ->
                    RISCVInstruction.RTYPE(type, r.nextInt(1, NUMBER_REGISTERS), r.nextInt(NUMBER_REGISTERS), r.nextInt(NUMBER_REGISTERS));
            case ITYPE -> {
                if (type == RISCV_TYPE.JALR) {
                    yield RISCVInstruction.ITYPE(type, r.nextInt(1, NUMBER_REGISTERS), r.nextInt(NUMBER_REGISTERS), r.nextLong(MAX_IMM_I) / 4 * 4);
                }
                yield RISCVInstruction.ITYPE(type, r.nextInt(1, NUMBER_REGISTERS), r.nextInt(NUMBER_REGISTERS), r.nextLong(MAX_IMM_I));
            }
            case STYPE ->
                    RISCVInstruction.STYPE(type, r.nextInt(NUMBER_REGISTERS), r.nextInt(NUMBER_REGISTERS), r.nextLong(MAX_IMM_I));
            case BTYPE ->
                    RISCVInstruction.BTYPE(type, r.nextInt(NUMBER_REGISTERS), r.nextInt(NUMBER_REGISTERS), (r.nextLong(MAX_IMM_B) / 4 * 4));
            case UTYPE ->
                    RISCVInstruction.UTYPE(type, r.nextInt(1, NUMBER_REGISTERS), r.nextLong(MAX_IMM_I - 1, MAX_IMM_U));
            case JTYPE -> RISCVInstruction.JTYPE(type, r.nextInt(1, NUMBER_REGISTERS), (r.nextLong(MAX_IMM_J) / 4 * 4));
        };
    }
}
