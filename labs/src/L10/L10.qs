// run on single test without messages output:
// pytest -s tests/test_L10.py::test_L10E01
//
// Note: Use little endian ordering when storing and retrieving integers from
// qubit registers in this lab.
//
// pytest -sv tests/test_L10.py::test_L10E01

namespace MITRE.QSD.L10 {
    // open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Unstable.Arithmetic;

    /// Half Adder
    /// Input:
    /// Two qubits a and b
    /// Carry in c, qubit
    ///
    /// Output:
    /// Nothing
    /// calculates the sum of a and b
    /// calculates the carry out
    operation E00_Half_Adder(a: Qubit,
                             b: Qubit,
                             sum: Qubit,
                             carryIn: Qubit) : Unit {
        // b = a XOR b
        CNOT(a, b);
        // sum = a XOR b
        CNOT(a, sum);
        // Carry = a AND b
        CCNOT(a, b, carryIn);
    }

    operation E00_Full_Adder(a: Qubit,
                             b: Qubit,
                             carryIn: Qubit,
                             sum: Qubit,
                             carryOut: Qubit) : Unit {

        CNOT(a, sum);
        CNOT(b, sum);
        CNOT(carryIn, sum);

        CCNOT(a, b, carryOut);
        CCNOT(a, carryIn, carryOut);
        CCNOT(b, carryIn, carryOut);
    }

    operation E00_Add_Two_Ints(a: Int, b: Int, carryIn: Int) : (Int, Int) {
        // Check if input is valid and exit if not
        let (inputNumQubitsEach, numInputQubitsTotal, valid) = E02_InputHandling(a, b, carryIn);
        if not valid { Message($"[Error] Invalid input. Exiting."); return (0, 0); }
        Message($"[Checkpoint] Input validation done"); Message("");

        // Allocate qubits and encode a, b, carryIn into qubits
        use (a_reg, b_reg, carryOut_reg, sum_reg) =
            (Qubit[inputNumQubitsEach], Qubit[inputNumQubitsEach], Qubit(), Qubit[inputNumQubitsEach + 1]);

        // Encode a and b into qubits
        mutable inputCounter = 0;
        for inputVal in [a, b] {
            let bits = IntAsBoolArray(inputVal, inputNumQubitsEach);
            for i in 0 .. Length(bits) - 1 {
                // apply X gate if bool True in binary representation
                if bits[i] { X(a_reg[i]); }
            }
            set inputCounter += 1;
        }

        // Encode carryIn into qubit (2nd to last qubit)
        if carryIn == 1 { X(carryOut_reg); }

        // Use Full Adder to add a and b
        mutable (a_idx, b_idx) = (0, 0);
        mutable (sum_idx, carry_idx) =  (0, 0);

        for i in 0 .. inputNumQubitsEach - 1 {
            E00_Full_Adder(a_reg[a_idx], b_reg[b_idx], carryOut_reg, carryOut_reg, sum_reg[sum_idx]);
            set (a_idx, b_idx) = (a_idx + 1, b_idx + 1);
            set (sum_idx, carry_idx) = (sum_idx + 1, carry_idx + 1);
        }

        // Measure the qubits
        mutable sum = 0;
        for i in 0 .. inputNumQubitsEach - 1 {
            set sum += M(sum_reg[i]) == One ? 1 | 0;
        }

        // carryIn XOR Sum MSB for carryOut
        CNOT(sum_reg[inputNumQubitsEach - 1], carryOut_reg);

        mutable carryOut = M(carryOut_reg) == One ? 1 | 0;
        Message(""); Message($"[Info] Sum: {sum}, Carry Out: {carryOut}");
        Message($"[Checkpoint] Measurement done"); Message("");

        // Clean up and return sum and carryOut
        ResetAll(a_reg);
        ResetAll(b_reg);
        ResetAll(sum_reg);
        Reset(carryOut_reg);
        Message(""); Message($"[RETURN] Sum: {sum}, Carry Out: {carryOut}");
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

        DumpMachine();

        // Measure the qubits
        set sum = M(qubits[2]) == One ? 1 | 0;
        set carryOut = M(qubits[3]) == One ? 1 | 0;

        // Reset qubits
        ResetAll(qubits);

        Message($"Sum: {sum}, Carry Out: {carryOut}");
        return (sum, carryOut);
    }


    /// Input Handling
    /// Input:
    /// Two integers a and b
    /// Carry in c
    ///
    /// Output:
    /// Two integers a and b
    /// The sum of a and b
    /// Carry out c
    /// Boolean indicating if input is valid
    operation E02_InputHandling(a: Int, b: Int, carryIn: Int) : (Int, Int, Bool) {
        // if a == 15 then with Ceiling(Lg(IntAsDouble(15))) = 4 qubits needed for a
        // if b == 17 then with Ceiling(Lg(IntAsDouble(17))) = 5 qubits needed for b
        Message(""); Message($"[Info] a: {a}, b: {b}, carryIn: {carryIn}");

        if a < 0 or b < 0 or carryIn < 0 or carryIn > 1 {
            Message($"[Error] Negative numbers not supported and carryIn must be 0 or 1. Exiting.");
            return (0, 0, false);
        }

        // storing 512 takes 2^9 + 1 bits since 2^9 = 512 = 1000000000 (10 bits) and 511 = 111111111 (9 bits)
        let a_min_qubits = MaxI(1, Ceiling(Lg(IntAsDouble(a + 1))));
        let b_min_qubits = MaxI(1, Ceiling(Lg(IntAsDouble(b + 1))));
        Message($"[Info] a_min_qubits: {a_min_qubits}, b_min_qubits: {b_min_qubits}");

        // use padding to make sure both a and b have same number of qubits later
        // add extra qubit for overflow
        let inputNumQubitsEach = MaxI(a_min_qubits, b_min_qubits) + 1;

        let MAX_QUBITS = 10;
        if inputNumQubitsEach > MAX_QUBITS + 1 {
            Message($"[Error] Cannot handle numbers this large. Max value is 2^10 - 1 = 1023");
            Message($"Max qubits: {MAX_QUBITS}, requested: {inputNumQubitsEach}");
            return (0, 0, false);
        }

        // a qubits, b qubits, carry In/Out, and sum qubits
        mutable numInputQubitsTotal = 2 * inputNumQubitsEach + 1 + inputNumQubitsEach + 1;

        let n = inputNumQubitsEach;
        Message($"[Info] Qubits needed: \{total: {numInputQubitsTotal}; a: {n}, b: {n}, carryIn/Out: 1, sum: {n}\}");
        return (inputNumQubitsEach, numInputQubitsTotal, true);
    }


    /// Decimal to Binary Array
    /// Qubits are little endian
    /// qubits are used and then reset
    ///
    /// Input:
    /// Integer num
    /// Integer bitSize
    /// String name
    ///
    /// Output:
    /// Integer array of binary representation of num
    operation E_DecToBin(num: Int,
                         bitSize: Int,
                         name: String) : Int[] {
        // Message($"[Info] Converting {name}: {a} from decimal to Binary Array");
        let bool_arr = IntAsBoolArray(num, bitSize);
        mutable idx_arr = [0, size=bitSize];
        mutable bin_arr = [0, size=bitSize];
        for i in 0 .. bitSize - 1 {
            set idx_arr w/= i <- i;
            if bool_arr[i] { set bin_arr w/= i <- 1; }
        }
        Message($"{name}_idx: LSB {idx_arr} MSB");
        Message($"{name}_bin: LSB {bin_arr} MSB     {name}: {num}");

        // show what it looks like as qubits
        use qubits = Qubit[bitSize];

        for i in 0 .. bitSize - 1 {
            if bin_arr[i] == 1 { X(qubits[i]); }
        }

        DumpMachine(); Message($"[Checkpoint] {name} encoded"); Message("");
        ResetAll(qubits);

        return bin_arr;
    }


    operation EncodeBinaryArrayToQubits(bin_arr: Int[], qubits: Qubit[]) : Unit {
        let bitSize = Length(bin_arr);

        for i in 0 .. bitSize - 1 {
            if bin_arr[i] == 1 { X(qubits[i]); }
        }

    }


    // break into smaller steps to debug
    // measurement as one for example

    // entry point - for debugger
    // @entry_point
    // breakpoints don't work...
    //

    // where do expectations change from what's happening from program in reality
    // unit test subcomponents

    // can measure qubits and print values ... better to have measurement in unit tests
    // than in program
    // dump register - try this to see sum reg, carry reg, etc.
    // do measurement in unit tests

    ////////////////
    // 996+1024 = 2020! Multiply final carry by 2^10 and add to total and it works
    ///////////////
    // DO THISSSSSSSS



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
    operation E03_FullAdder_nBits (a: Int,
                                   b: Int) : (Int, Int) {

        // Check if input is valid and exit if not
        // let (inputNumQubitsEach, numInputQubitsTotal, valid) = E02_InputHandling(a, b, 0);
        // let (inputNumQubitsEach, numInputQubitsTotal, valid) = E02_InputHandling(a, b);
        // if not valid { Message($"[Error] Invalid input. Exiting."); return (0, 0); }
        Message($"Testing a + b : {a} + {b}");
        Message($"[Checkpoint] Input validation done"); Message("");

        /////////////////////////////////////////////////////////////////////////////////////////
        // Allocate qubits and encode a, b into qubits
        let neededQubits = 10;

        // encode decimal a,b into qubits
        use reg_a = Qubit[neededQubits]; // max 2^10 - 1 = 1023
        use reg_b = Qubit[neededQubits]; // max 2^10 - 1 = 1023

        // Helper function to convert decimal to binary array and show what it looks like as qubits
        let a_bits = E_DecToBin(a, neededQubits, "a");
        let b_bits = E_DecToBin(b, neededQubits, "b");
        // flip qubits to match binary array representing input decimal vals a, b
        EncodeBinaryArrayToQubits(a_bits, reg_a);
        EncodeBinaryArrayToQubits(b_bits, reg_b);

        DumpMachine(); Message($"[Checkpoint] Encoding done"); Message("");

        /////////////////////////////////////////////////////////////////////////////////////////
        // Use Full Adder to add a and b
        use reg_c = Qubit[neededQubits + 1];
        use reg_s = Qubit[neededQubits + 1]; // max 2^11 - 1 = 2047; 1023 + 1023 + 1 = 2047

        // LSB
        E00_Full_Adder(reg_a[0], reg_b[0], reg_c[0], reg_s[0], reg_c[1]);
        DumpMachine();

        // LSB + 1 ... MSB - 1
        for i in 1 .. neededQubits - 2 {
            E00_Full_Adder(reg_a[i], reg_b[i], reg_c[i], reg_s[i], reg_c[i + 1]);
            DumpMachine();
        }

        // MSB
        let nq = neededQubits;
        E00_Full_Adder(reg_a[nq - 1], reg_b[nq - 1], reg_c[nq - 1], reg_s[nq - 1], reg_c[nq]);

        DumpMachine(); Message($"[Checkpoint] Full Adder done"); Message("");

        /////////////////////////////////////////////////////////////////////////////////////////
        // Measure the qubits and take the sum
        mutable sumBits = [0, size = neededQubits + 1];
        mutable sumIdx = [0, size = neededQubits + 1];
        mutable sum = 0;

        for i in 0 .. Length(reg_s) - 1 {
            // += to decimal sum if measurement is 1 at index i
            if (M(reg_s[i]) == One) { // Use `n - i - 1` instead of `i` to measure the qubits in `reg_s`
                let idx = Length(reg_s) - i - 1;
                set sum += 2^i;
                // set sum += 2^idx;
                Message($"Sum bit (idx {i} = 1); sum: {sum}     += 2^{i}");
                set sumBits w/= i <- 1;
            } else {
                Message($"Sum bit (idx {i} = 0); sum: {sum}"); // Use `n - i - 1` instead of `i` in the message
            }
            set sumIdx w/= i <- i;
        }

        Message($"idx:  LSB {sumIdx} MSB");
        Message($"Sum bits: {sumBits};  sum = {sum}"); DumpMachine();


        mutable carryBits = [0, size = neededQubits + 1];
        mutable carryIdx = [0, size = neededQubits + 1];
        mutable carryOut = 0;

        for i in 0 .. Length(reg_c) - 1 {
            // += to decimal sum if measurement is 1 at index i
            if (M(reg_c[i]) == One) { // Use `n - i - 1` instead of `i` to measure the qubits in `reg_c`
                // set carryOut += 2^idx;
                Message($"Carry bit (idx {i} = 1)"); // Use `n - i - 1` instead of `i` in the message
                set carryBits w/= i <- 1;
            } else {
                Message($"Carry bit (idx {i} = 0)");
            }
            set carryIdx w/= i <- i;
        }

        // Measuring complete
        ResetAll(reg_a + reg_b + reg_c + reg_s);

        // adds nothing if carryOut is 0, adds 2^neededQubits if carryOut is 1
        // += {0,1}*2^Length(reg_c) to sum
        set sum += carryBits[neededQubits] * 2^neededQubits + carryBits[0];
        Message($"Sum with carryOut MSB accounted for (for overflow sums): {sum}"); Message("");

        Message($"idx:    LSB {carryIdx} MSB"); Message("");

        let carryOutLSB = carryBits[0];
        Message($"Carry bits: {carryBits};  carryOut = {carryOutLSB}");

        Message(""); Message($"[RETURN] Sum: {sum}, Carry Out: {carryOutLSB}");
        return (sum, carryOutLSB);

        // ONLY RETURN SUM.....!!!!!!!!!! that is the point of LSB carryout
        // return sum;
    }



    operation E04_temp(a: Int, b: Int, carryIn: Int) : (Int, Int) {
        // Check if input is valid and exit if not
        let (inputNumQubitsEach, numInputQubitsTotal, valid) = E02_InputHandling(a, b, carryIn);
        if not valid { Message($"[Error] Invalid input. Exiting."); return (0, 0); }
        Message($"[Checkpoint] Input validation done"); Message("");

        /////////////////////////////////////////////////////////////////////////////////////////
        // Allocate qubits and encode a, b, carryIn into qubits
        use qubits = Qubit[numInputQubitsTotal];


        mutable inputCounter = 0;
        for inputVal in [a, b] {
            let bits = IntAsBoolArray(inputVal, inputNumQubitsEach);
            for i in 0 .. Length(bits) - 1 {
                // apply X gate if bool True in binary representation
                if bits[i] { X(qubits[inputCounter]); }
                set inputCounter += 1;
            }
        }
        // Encode carryIn into qubit (2nd to last qubit)
        if carryIn == 1 { X(qubits[Length(qubits) - 2]); }

        Message($"Length of qubits used: {Length(qubits)}"); DumpMachine();
        Message($"[Checkpoint] Encoding done"); Message("");

        /////////////////////////////////////////////////////////////////////////////////////////
        // Use Full Adder to add a and b
        mutable (a_idx, b_idx) = (0, inputNumQubitsEach);
        mutable (sum_idx, carry_idx) =  (2*inputNumQubitsEach, 2*inputNumQubitsEach + 1);

        for i in 0 .. inputNumQubitsEach - 1 {
            Message($"Looking at index {i} and at qubit: {i + inputNumQubitsEach}");

            CCNOT(qubits[a_idx], qubits[b_idx], qubits[carry_idx]);
            CNOT(qubits[a_idx], qubits[b_idx]);
            CCNOT(qubits[b_idx], qubits[sum_idx], qubits[carry_idx]);
            CNOT(qubits[b_idx], qubits[sum_idx]);
            CNOT(qubits[a_idx], qubits[b_idx]);

            set (a_idx, b_idx) = (a_idx + 1, b_idx + 1);
            set (sum_idx, carry_idx) = (sum_idx + 1, carry_idx + 1);
        }
        DumpMachine(); Message($"[Checkpoint] Full Adder done"); Message("");

        /////////////////////////////////////////////////////////////////////////////////////////
        // Measure the qubits

        // convert qubits to integers
        mutable sumBits = [0, size=inputNumQubitsEach];
        for i in 0 .. inputNumQubitsEach - 1 {
            Message($"Looking at index {i} and at qubit: {i + inputNumQubitsEach}");
            // mark 1 if qubit is One at each index
            set sumBits w/= i <- (M(qubits[i + inputNumQubitsEach]) == One ? 1 | 0); // doesnt work
            set sumBits w/= i <- (M(qubits[i + inputNumQubitsEach*2]) == One ? 1 | 0); // works for 4 qubits
            Message($"Sum bits {i}: {sumBits[i]}");
        }
        Message($"Sum bits: {sumBits}"); DumpMachine();

        // use power of 2 to convert binary to integer
        // with the first bit being the least significant bit
        mutable sum = 0;
        for i in 0 .. Length(sumBits) - 1 {
            set sum += sumBits[i] * 2^i;
        }

        // carryIn XOR Sum MSB for carryOut
        CNOT(qubits[Length(qubits) - 2], qubits[Length(qubits) - 1]);

        // mutable sum =      M(qubits[Length(qubits) - 2]) == One ? 1 | 0;
        mutable carryOut = M(qubits[Length(qubits) - 1]) == One ? 1 | 0;
        Message(""); Message($"[Info] Sum: {sum}, Carry Out: {carryOut}");
        Message($"[Checkpoint] Measurement done"); Message("");

        /////////////////////////////////////////////////////////////////////////////////////////
        // Clean up and return sum and carryOut
        ResetAll(qubits);
        Message(""); Message($"[RETURN] Sum: {sum}, Carry Out: {carryOut}");
        return (sum, carryOut);
    }
}
