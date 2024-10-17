package contractgen.riscv.isa.tests;

import contractgen.TestCase;
import contractgen.riscv.isa.*;
import contractgen.riscv.isa.contract.RISCVTestResult;
import contractgen.riscv.isa.contract.RISCVObservation;
import contractgen.riscv.isa.contract.RISCV_OBSERVATION_TYPE;
import contractgen.util.Pair;

import java.util.*;
import java.util.stream.Stream;

/**
 * A generator for RISC-V test cases.
 */
public class RISCVTestGenerator {
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
    RISCVTestGenerator(Set<RISCV_SUBSET> subsets, long seed, int repetitions) {
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
    RISCVTestGenerator(Set<RISCV_SUBSET> subsets, Set<RISCV_OBSERVATION_TYPE> allowed_observations, long seed, int repetitions) {
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
            Map<Integer, Integer> registers = randomRegisters();
            List<RISCVInstruction> suffix = randomSequence(r.nextInt(5, 25));
            RISCVInstruction instruction = randomInstructionFromType(type);
            for (RISCV_OBSERVATION_TYPE observation : allowed_observations) {
                Pair<List<RISCVInstruction>, List<RISCVInstruction>> prefix = alterObservation(observation, instruction);
                if (prefix != null) {
                    // ensure jalr are always aligned
                    if (type == RISCV_TYPE.JALR) {
                        prefix = new Pair<List<RISCVInstruction>,List<RISCVInstruction>>(
                            insertAtSecondToLast(prefix.left(), RISCVInstruction.ANDI(prefix.left().get(prefix.left().size() - 1).rs1(), prefix.left().get(prefix.left().size() - 1).rs1(), MAX_IMM_I - 4)), 
                            insertAtSecondToLast(prefix.right(), RISCVInstruction.ANDI(prefix.right().get(prefix.right().size() - 1).rs1(), prefix.right().get(prefix.right().size() - 1).rs1(), MAX_IMM_I - 4)));
                    }
                    cases.add(new RISCVTestCase(
                            new RISCVProgram(registers, Stream.concat(prefix.left().stream(), suffix.stream()).toList()),
                            new RISCVProgram(registers, Stream.concat(prefix.right().stream(), suffix.stream()).toList()),
                            Integer.max(prefix.left().size() + suffix.size(), prefix.right().size() + suffix.size()), new RISCVTestResult(Set.of(new RISCVObservation(type, observation)), true, index), index++));
                }
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
     * Alters a given instruction to introduce a specific possible leakage. In most cases this requires executing
     * different instructions before the relevant instruction to alter the architectural state accordingly.
     *
     * @param type        The type of observation that should be triggered.
     * @param instruction The instruction to be altered.
     * @return A pair of sequences of instructions.
     */
    private Pair<List<RISCVInstruction>, List<RISCVInstruction>> alterObservation(RISCV_OBSERVATION_TYPE type, RISCVInstruction instruction) {
        return switch (type) {
            case FORMAT, OPCODE, FUNCT7, FUNCT3 -> null; //new Pair<>(List.of(instruction), randomSequence(1));
            case RD -> {
                if (instruction.rd() == null) yield null;
                RISCVInstruction ins1 = instruction.cloneAlteringRD(r.nextInt(1, NUMBER_REGISTERS));
                RISCVInstruction ins2 = instruction.cloneAlteringRD(r.nextInt(1, NUMBER_REGISTERS));
                yield new Pair<>(List.of(ins1), List.of(ins2));
            }
            case RS1 -> {
                if (instruction.rs1() == null) yield null;
                RISCVInstruction ins1 = instruction.cloneAlteringRS1(r.nextInt(NUMBER_REGISTERS));
                RISCVInstruction ins2 = instruction.cloneAlteringRS1(r.nextInt(NUMBER_REGISTERS));
                yield new Pair<>(List.of(ins1), List.of(ins2));
            }
            case RS2 -> {
                if (instruction.rs2() == null) yield null;
                RISCVInstruction ins1 = instruction.cloneAlteringRS2(r.nextInt(NUMBER_REGISTERS));
                RISCVInstruction ins2 = instruction.cloneAlteringRS2(r.nextInt(NUMBER_REGISTERS));
                yield new Pair<>(List.of(ins1), List.of(ins2));
            }
            case IMM -> {
                if (instruction.imm() == null) yield null;
                long imm_1 = r.nextLong(getBound(instruction));
                long imm_2 = r.nextLong(getBound(instruction));
                if (instruction.type().getFormat() == RISCV_FORMAT.BTYPE || instruction.type() == RISCV_TYPE.JAL || instruction.type() == RISCV_TYPE.JALR) {
                    imm_1 = imm_1 / 4 * 4;
                    imm_2 = imm_2 / 4 * 4;
                }
                RISCVInstruction ins1 = instruction.cloneAlteringIMM(imm_1);
                RISCVInstruction ins2 = instruction.cloneAlteringIMM(imm_2);
                yield new Pair<>(List.of(ins1), List.of(ins2));
            }
            case REG_RS1 -> {
                if (instruction.rs1() == null) yield null;
                RISCVInstruction ins1 = RISCVInstruction.ADDI(instruction.rs1(), 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction ins2 = RISCVInstruction.ADDI(instruction.rs1(), 0, r.nextLong(MAX_IMM_I));
                yield new Pair<>(List.of(ins1, instruction), List.of(ins2, instruction));
            }
            case REG_RS2 -> {
                if (instruction.rs2() == null) yield null;
                RISCVInstruction ins1 = RISCVInstruction.ADDI(instruction.rs2(), 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction ins2 = RISCVInstruction.ADDI(instruction.rs2(), 0, r.nextLong(MAX_IMM_I));
                yield new Pair<>(List.of(ins1, instruction), List.of(ins2, instruction));
            }
            case MEM_ADDR -> {
                if (instruction.rs1() == null) yield null;
                long address = r.nextLong(MAX_IMM_I);
                RISCVInstruction val1 = RISCVInstruction.ADDI(31, 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction val2 = RISCVInstruction.ADDI(30, 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction instr_addr = RISCVInstruction.ADDI(instruction.rs1(), 0, address);
                RISCVInstruction ins1 = RISCVInstruction.SW(instruction.rs1(), 31, 0);
                RISCVInstruction ins2 = RISCVInstruction.SW(instruction.rs1(), 30, 0);
                yield new Pair<>(List.of(val1, val2, instr_addr, ins1, instruction), List.of(val1, val2, instr_addr, ins2, instruction));
            }
            case MEM_W_DATA -> {
                if (instruction.rs2() == null) yield null;
                long address = r.nextLong(MAX_IMM_I);
                RISCVInstruction val1 = RISCVInstruction.ADDI(31, 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction val2 = RISCVInstruction.ADDI(30, 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction instr_addr = RISCVInstruction.ADDI(instruction.rs2(), 0, address);
                RISCVInstruction ins1 = RISCVInstruction.SW(instruction.rs2(), 31, 0);
                RISCVInstruction ins2 = RISCVInstruction.SW(instruction.rs2(), 30, 0);
                yield new Pair<>(List.of(val1, val2, instr_addr, ins1, instruction), List.of(val1, val2, instr_addr, ins2, instruction));
            }
            case REG_RD -> {
                if (instruction.rd() == null) yield null;
                RISCVInstruction ins1 = instruction.cloneAlteringRD(r.nextInt(NUMBER_REGISTERS));
                RISCVInstruction ins2 = instruction.cloneAlteringRD(r.nextInt(NUMBER_REGISTERS));
                yield new Pair<>(List.of(ins1), List.of(ins2));
            }
            case MEM_R_DATA -> {
                if (instruction.imm() == null || instruction.rs1() == null) yield null;
                long address = r.nextLong(MAX_IMM_I);
                RISCVInstruction val1 = RISCVInstruction.ADDI(31, 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction val2 = RISCVInstruction.ADDI(30, 0, r.nextLong(MAX_IMM_I));
                RISCVInstruction instr_addr_1 = RISCVInstruction.ADDI(instruction.rs1(), 0, address);
                RISCVInstruction ins1 = RISCVInstruction.SW(instruction.rs1(), 31, 0);
                RISCVInstruction ins2 = RISCVInstruction.SW(instruction.rs1(), 30, 0);
                RISCVInstruction instr_addr_2 = RISCVInstruction.ADDI(instruction.rs1(), instruction.rs1(), instruction.imm());
                yield new Pair<>(List.of(val1, val2, instr_addr_1, ins1, instr_addr_2, instruction), List.of(val1, val2, instr_addr_1, ins2, instr_addr_2, instruction));
            }
            case IS_BRANCH -> null;
            case BRANCH_TAKEN -> null;
            case IS_ALIGNED -> null;
            case IS_HALF_ALIGNED -> null;
            case NEW_PC -> null;
            case RAW_RS1_2, RAW_RS1_3, RAW_RS1_4, RAW_RS2_2, RAW_RS2_3, RAW_RS2_4, WAW_2, WAW_3, WAW_4 -> null;
            case RAW_RS1_1 -> {
                if (instruction.rs1() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs1(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                yield new Pair<>(List.of(add1, instruction), List.of(add2, instruction));
            }
/*            case RAW_RS1_2 -> {
                if (instruction.rs1() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs1(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, instruction), List.of(add2, nop, instruction));
            }
            case RAW_RS1_3 -> {
                if (instruction.rs1() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs1(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, nop, instruction), List.of(add2, nop, nop, instruction));
            }
            case RAW_RS1_4 -> {
                if (instruction.rs1() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs1(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, nop, nop, instruction), List.of(add2, nop, nop, nop, instruction));
            }

 */
            case RAW_RS2_1 -> {
                if (instruction.rs2() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs2(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                yield new Pair<>(List.of(add1, instruction), List.of(add2, instruction));
            }
            /*
            case RAW_RS2_2 -> {
                if (instruction.rs2() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs2(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, instruction), List.of(add2, nop, instruction));
            }
            case RAW_RS2_3 -> {
                if (instruction.rs2() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs2(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, nop, instruction), List.of(add2, nop, nop, instruction));
            }
            case RAW_RS2_4 -> {
                if (instruction.rs2() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rs2(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, nop, nop, instruction), List.of(add2, nop, nop, nop, instruction));
            }
             */
            case WAW_1 -> {
                if (instruction.rd() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rd(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                yield new Pair<>(List.of(add1, instruction), List.of(add2, instruction));
            }
            /*
            case WAW_2 -> {
                if (instruction.rd() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rd(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, instruction), List.of(add2, nop, instruction));
            }
            case WAW_3 -> {
                if (instruction.rd() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rd(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, nop, instruction), List.of(add2, nop, nop, instruction));
            }
            case WAW_4 -> {
                if (instruction.rd() == null) yield null;
                RISCVInstruction add1 = RISCVInstruction.ADD(instruction.rd(), 0, 0);
                RISCVInstruction add2 = RISCVInstruction.ADD(0, 0, 0);
                RISCVInstruction nop = RISCVInstruction.NOP();
                yield new Pair<>(List.of(add1, nop, nop, nop, instruction), List.of(add2, nop, nop, nop, instruction));
            }

             */
        };
    }

    /**
     * @param instruction an instruction
     * @return the maximum immediate value.
     */
    private static long getBound(RISCVInstruction instruction) {
        return switch (instruction.type().getFormat()) {
            case RTYPE -> 0L;
            case ITYPE, STYPE -> MAX_IMM_I;
            case BTYPE -> MAX_IMM_B;
            case UTYPE -> MAX_IMM_U;
            case JTYPE -> MAX_IMM_J;
        };
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
     * @param type the ytype of the desired instruction
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
