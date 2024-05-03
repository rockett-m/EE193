// run on single test without messages output:
// pytest -s tests/test_L10.py::test_L10E01
//
// Note: Use little endian ordering when storing and retrieving integers from
// qubit registers in this lab.
//
// pytest -sv tests/test_L10.py::test_L10E01

namespace MITRE.QSD.L10 {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Unstable.Arithmetic;


    /// Full Adder
    /// Input:
    /// Two integers a and b
    /// Carry in c, 0
    ///
    /// Output:
    /// Two integers a and b
    /// The sum of a and b
    /// Carry out c
    ///
    /// Write Endianess: Little Endian
    operation E01_FullAdder_1Bit (a: Int, b: Int, carryIn: Int) : (Int, Int) {

        if a < 0 or a > 1 or b < 0 or b > 1 or carryIn < 0 or carryIn > 1 {
            Message($"[Error] Invalid input. a, b, carryIn must be 0 or 1");
            return (0, 0);
        }

        use qubits = Qubit[4];
        mutable (sum, carryOut) = (0, 0);

        // DumpMachine();

        // Encode a into qubit (apply X gate if a == 1)
        if a == 1 { X(qubits[0]); }
        // Encode b into qubits
        if b == 1 { X(qubits[1]); }
        // Encode carryIn into qubit
        if carryIn == 1 { X(qubits[2]); }

        // DumpMachine();

        // Apply Full Adder
        CCNOT(qubits[0], qubits[1], qubits[3]);
        CNOT(qubits[0], qubits[1]);
        CCNOT(qubits[1], qubits[2], qubits[3]);
        CNOT(qubits[1], qubits[2]);
        CNOT(qubits[0], qubits[1]);

        // DumpMachine();

        // Measure the qubits
        set sum = M(qubits[2]) == One ? 1 | 0;
        set carryOut = M(qubits[3]) == One ? 1 | 0;

        // Reset qubits
        ResetAll(qubits);

        Message($"Sum: {sum}, Carry Out: {carryOut}");
        return (sum, carryOut);
    }

    /// Full Adder
    /// Input:
    /// Two integers a and b
    /// Carry in c, 0
    ///
    /// Output:
    /// Two integers a and b
    /// The sum of a and b
    /// Carry out c
    ///
    /// Write Endianess: Little Endian
    ///
    operation E02_FullAdder_nBits (a: Int, b: Int, carryIn: Int) : (Int, Int) {
        // if a == 15 then with Ceiling(Lg(IntAsDouble(15))) = 4 qubits needed for a
        // if b == 17 then with Ceiling(Lg(IntAsDouble(17))) = 5 qubits needed for b
        Message("");
        Message($"[Info] a: {a}, b: {b}, carryIn: {carryIn}");

        if a < 0 or b < 0 or carryIn < 0 {
            Message($"[Error] Negative numbers not supported");
            return (0, 0);
        }

        let a_min_qubits = MaxI(1, Ceiling(Lg(IntAsDouble(a))));
        let b_min_qubits = MaxI(1, Ceiling(Lg(IntAsDouble(b))));
        Message($"[Info] a_min_qubits: {a_min_qubits}, b_min_qubits: {b_min_qubits}");

        // 2*max(a_qubits, b_qubits) = combined num qubits for a and b
        // use padding to make sure both a and b have same number of qubits later
        let inputNumQubitsEach = MaxI(a_min_qubits, b_min_qubits);

        // a qubits, b qubits, carry in/sum, and 0 in/carry out
        let numInputQubits = 2 * inputNumQubitsEach + 1 + 1;

        if numInputQubits > 22 {
            Message($"[Error] Cannot handle numbers this large. Max qubits: 22, requested: {numInputQubits}");
            return (0, 0);
        }

        Message($"[Info] Qubits needed: {numInputQubits}");
        Message($"[Info] aNumQubits: {inputNumQubitsEach}, bNumQubits: {inputNumQubitsEach}; carryIn/sum: 1; carryOut: 1");

        use qubits = Qubit[numInputQubits];
        mutable (sum, carryOut) = (0, 0);
        mutable inputCounter = 0;

        // Encode a into qubits
        let aBits = IntAsBoolArray(a, inputNumQubitsEach);
        for i in 0 .. Length(aBits) - 1 {
            // apply X gate if bool True in binary representation
            if aBits[i] { X(qubits[i]); }
            set inputCounter += 1;
        }

        // Encode b into qubits
        let bBits = IntAsBoolArray(b, inputNumQubitsEach);
        for i in 0 .. Length(bBits) - 1 {
            let index = inputCounter + i;
            // apply X gate if bool True in binary representation
            if bBits[i] { X(qubits[index]); }
            set inputCounter += 1;
        }

        // Encode carryIn into qubit (2nd to last qubit)
        if carryIn == 1 { X(qubits[inputCounter]); }

        Message($"[Info] Input Counter: {inputCounter}");
        DumpMachine();

        mutable (a_idx, b_idx) = (0, inputNumQubitsEach);


        // Chain Full Adders for each bit
        for i in 0 .. inputNumQubitsEach - 1 {

            Message($"Looking at qubits: {i}, {i + inputNumQubitsEach}");
            CCNOT(qubits[a_idx], qubits[b_idx], qubits[Length(qubits) - 1]);
            CNOT(qubits[a_idx], qubits[b_idx]);
            CCNOT(qubits[b_idx], qubits[Length(qubits) - 2], qubits[Length(qubits) - 1]);
            CNOT(qubits[b_idx], qubits[Length(qubits) - 2]);
            CNOT(qubits[a_idx], qubits[b_idx]);
            set (a_idx, b_idx) = (a_idx + 1, b_idx + 1);
        }
        // when measuring do sum of
        // M(qubits[i = 0]), M(qubits[i=0 + aNumQubits=5]) ...
        // M(qubits[i]), M(qubits[i + aNumQubits=5]) ...
        // M(qubits[i + 2*aNumQubits - 1]) == One ? 1 | 0;

        // apply X gate to a and b and carryIn qubits when bits == 1



        // Measure the qubits
        DumpMachine();



        set sum = M(qubits[Length(qubits) - 2]) == One ? 1 | 0;
        set carryOut = M(qubits[Length(qubits) - 1]) == One ? 1 | 0;
        Message("");
        Message($"[Info] Sum: {sum}, Carry Out: {carryOut}");

        ResetAll(qubits);


        return (sum, carryOut);
    }
}