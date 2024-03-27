// Quantum Software Development
// Lab 6: Simon's Algorithm
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 3/27.
// Note the section marked "CHALLENGE PROBLEMS" is optional.
// 5% extra credit is awarded for each challenge problem attempted;
// 10% for each implemented correctly.

namespace MITRE.QSD.L06 {

    // open MITRE.QSD.L01;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;


    /// # Summary
    /// This operation left-shifts the input register by 1 bit, putting the
    /// shifted version of it into the output register. For example, if you
    /// provide it with |1110> as the input, this will put the output into the
    /// state |1100>.
    ///
    /// # Input
    /// ## input
    /// The register to shift. It can be any length, and in any state.
    ///
    /// ## output
    /// The register to shift the input into. It must be the same length as
    /// the input register, and it must be in the |0...0> state. After this
    /// operation, it will be in the state of the input, left-shifted by 1 bit.
    operation LeftShiftBy1 (input : Qubit[], output : Qubit[]) : Unit {
        // Start at input[1]
        ResetAll(output);
        // Reset(output[Length(output) - 1]);
        for inputIndex in 1 .. Length(input) - 1 {
            // Copy input[i] to output[i-1]
            let outputIndex = inputIndex - 1;
            CNOT(input[inputIndex], output[outputIndex]);
        }
    }


    /// # Summary
    /// In this exercise, you are given a quantum operation that takes in an
    /// input and output register of the same size, and a classical bit string
    /// representing the desired input. Your goal is to run the operation in
    /// "classical mode", which means running it on a single input (rather
    /// than a superposition), and measuring the output (rather than the
    /// input).
    ///
    /// More specifically, you must do this:
    /// 1. Create a qubit register and put it in the same state as the input
    ///    bit string.
    /// 2. Run the operation with this input.
    /// 3. Measure the output register.
    /// 4. Return the output measurements as a classical bit string.
    ///
    /// This will be used by Simon's algorithm to check if the secret string
    /// and the |0...0> state have the same output value - if they don't, then
    /// the operation is 1-to-1 instead of 2-to-1 so it doesn't have a secret
    /// string.
    ///
    /// # Input
    /// ## op
    /// The quantum operation to run in classical mode.
    ///
    /// ## input
    /// A classical bit string representing the input to the operation.
    ///
    /// # Output
    /// A classical bit string containing the results of the operation.
    operation E01_RunOpAsClassicalFunc (
        op : ((Qubit[], Qubit[]) => Unit),
        input : Bool[]
    ) : Bool[] {
        // TODO
        // Create a qubit register and put it in the same state as the input
        use input_qubits = Qubit[Length(input)];
        for i in 0 .. Length(input) - 1 {
            // If the input bit is true, apply an X gate to make it |1>
            if input[i] { X(input_qubits[i]); }
        }

        // Run the operation with this input
        use output_qubits = Qubit[Length(input)];
        op(input_qubits, output_qubits);

        // Measure the output register
        mutable measured_output = [false, size=Length(input)];

        for i in 0 .. Length(input) - 1 {
            // If the output is |1>, set the corresponding bit to true
            set measured_output w/= i <- M(output_qubits[i]) == One;
        }

        ResetAll(input_qubits); ResetAll(output_qubits);

        return measured_output;
    }


    /// # Summary
    /// In this exercise, you must implement the quantum portion of Simon's
    /// algorithm. You are given a black-box quantum operation that is either
    /// 2-to-1 or 1-to-1, and a size that it expects for its input and output
    /// registers. Your goal is to run the operation as defined by Simon's
    /// algorithm, measure the input register, and return the result as a
    /// classical bit string.
    ///
    /// # Input
    /// ## op
    /// The black-box quantum operation being evaluated. It takes two qubit
    /// registers (an input and an output, both of which are the same size).
    ///
    /// ## inputSize
    /// The length of the input and output registers that the black-box
    /// operation expects.
    ///
    /// # Output
    /// A classical bit string representing the measurements of the input
    /// register.
    operation E02_SimonQSubroutine (
        op : ((Qubit[], Qubit[]) => Unit),
        inputSize : Int
    ) : Bool[] {
        // TODO
        use input_qubits = Qubit[inputSize];
        use output_qubits = Qubit[inputSize];

        ApplyToEach(H, input_qubits);
        op(input_qubits, output_qubits);
        ApplyToEach(H, input_qubits);

        mutable results = [false, size=inputSize];

        for i in 0 .. inputSize - 1 {
            // If the measurement is |1>, set the corresponding bit to true
            set results w/= i <-  M(input_qubits[i]) == One;
        }

        ResetAll(input_qubits); ResetAll(output_qubits);

        return results;
    }


    //////////////////////////////////
    /// === CHALLENGE PROBLEMS === ///
    //////////////////////////////////

    // The problems below are extra quantum operations you can implement to try
    // Simon's algorithm on.


    /// # Summary
    /// In this exercise, you must right-shift the input register by 1 bit,
    /// putting the shifted version of it into the output register. For
    /// example, if you are given the input |1110> you must put the output
    /// into the state
    /// |0111>.
    ///
    /// # Input
    /// ## input
    /// The register to shift. It can be any length, and in any state.
    ///
    /// ## output
    /// The register to shift the input into. It must be the same length as
    /// the input register, and it must be in the |0...0> state. After this
    /// operation, it will be in the state of the input, right-shifted by 1
    /// bit.
    ///
    /// # Remarks
    /// This function should have the secret string |10...0>. For example, for
    /// a three-qubit register, it would be |100>. If the unit tests provide
    /// that result, then you've implemented it properly.
    operation C01_RightShiftBy1 (input : Qubit[], output : Qubit[]) : Unit {
        // TODO
        ResetAll(output);
        // Reset(output[0]);
        use output_qubits = Qubit[Length(input)];
        // first qubit is 0 and should remain 0
        for i in 1 .. Length(input) - 1 {
            CNOT(input[i-1], output[i]);
        }
        mutable result = [false, size=Length(input)];
        for i in 0 .. Length(input) - 1 {
            // If the measurement is |1>, set the corresponding bit to true
            set result w/= i <- M(output[i]) == One;
        }
    }


    /// # Summary
    /// In this exercise, you must implement the black-box operation shown in
    /// the lecture on Simon's algorithm. As a reminder, this operation takes
    /// in a  3-qubit input and a 3-qubit output. It has this input/output
    /// table:
    ///
    ///  Input | Output
    /// ---------------
    ///   000  |  101
    ///   001  |  010
    ///   010  |  000
    ///   011  |  110
    ///   100  |  000
    ///   101  |  110
    ///   110  |  101
    ///   111  |  010
    ///
    /// # Input
    /// ## input
    /// The input register. It will be of size 3, but can be in any state.
    ///
    /// ## output
    /// The output register. It will be of size 3, and in the state |000>.
    ///
    /// # Remarks
    /// To implement this operation, you'll need to find patterns in the
    /// input/output pairs to determine a set of gates that produces this
    /// table. Hint: you can do it by only using the X gate, and controlled
    /// variants of the X gate (CNOT and CCNOT).
    operation C02_SimonBB (input : Qubit[], output : Qubit[]) : Unit {
        // TODO

        ///  000  |  101
        open Microsoft.Quantum.Arrays;
        ApplyToEach(X, input[0..2]);
        CCNOT(input[0], input[1], output[0]);
        CCNOT(input[1], input[2], output[2]);
        ApplyToEach(X, input[0..2]);

        //   001  |  010
        ApplyToEach(X, input[0..1]);
        CCNOT(input[0], input[1], output[1]);
        ApplyToEach(X, input[0..1]);

        //   011  |  110
        X(input[0]);
        CCNOT(input[1], input[2], output[0]);
        X(input[0]);

        //   101  |  110
        X(input[1]);
        CCNOT(input[0], input[2], output[0]);
        X(input[1]);

        //   110  |  101
        X(input[2]);
        CCNOT(input[0], input[1], output[0]);
        X(input[2]);

        //   111  |  010
        CCNOT(input[0], input[1], output[1]);
    }
}

// notes on final challenge problem C02_SimonBB
// odd number of 1s in the input: then then odd number of 1s in the output
// even number of 1s in the input: then even number of 1s in the output

//  Input | Output
// ---------------
//   100  |  000 // dont change anything (outputs)
//   010  |  000 // dont change anything
// when there is only one 1 in the input in qubit position 0 or 1, the output is 000

//   001  |  010 // done
//   111  |  010 // done

//   110  |  101 // done
//   000  |  101 // done

//   011  |  110 // done
//   101  |  110 // done
// when there are two 1s in the input, both with LSB qubit 2 as a 1, the output is 110

// got sporadic passes (due to random number generation) so used count var and if...elif...else
// to try and pass a higher percentage of the time

//  Input | Output
// ---------------
//   000  |  101    //                                X(output[0]), X(output[2])
//   001  |  010    // shiftLeftBy1
//   010  |  000    // shiftLeftBy1, shiftLeftBy1     or leave output as is
//   011  |  110    // shiftLeftBy1
//   100  |  000    // shiftLeftBy1                   or leave output as is
//   101  |  110    // shiftLeftBy1,                  X(output[0])
//   110  |  101    // shiftLeftBy1,                  X(output[2])
//   111  |  010    // shiftLeftBy1, shiftLeftBy1,    shiftRightBy1

// 1 in input, 2 in output for these cases
//  000 : 000{2}, 000{4}
//  010 : 010{1}, 010{7}
//  101 : 101{0}, 101{6}
//  110 : 110{3}, 110{5}




// invalid because we entangled ancilla with inputs
// we are not supposed to measure the inputs
// the entanglement should not happen to not alter state as well


// // DumpMachine();
// //  Input | Output
// //   000  |  101
// ApplyToEach(X, input[0..2]); // attempt to get input as |111>
// use ancilla = Qubit();
// Controlled X(input[0..2], ancilla); // if input is |111>, ancilla will be 1
// if M(ancilla) == One {
//     // LeftShiftBy1(input, output); // |111> -> |110>
//     // LeftShiftBy1(output, output); // |110> -> |100>
//     // X(output[2]);
//     X(output[2]); X(output[0]); //works also
// }
// Reset(ancilla);
// ApplyToEach(X, input[0..2]);

// //  Input | Output
// //   001  |  010
// within { X(input[0]); X(input[1]); }
// apply {
//     use ancilla = Qubit();
//     // we know first 2 qubits are 1 due to the within condition
//     // if the last qubit is 1, then ancilla will be 1, and trigger our logic
//     Controlled X(input[0..2], ancilla);
//     // use controls of ancilla and input[2]
//     if M(ancilla) == One {
//         // |111> -> |110>; |110> -> |100>; |100> -> |010>
//         // LeftShiftBy1(input, output);
//         // LeftShiftBy1(output, output);
//         // C01_RightShiftBy1(output, output);
//         X(output[1]);
//     }
//     Reset(ancilla);
// }

// //  Input | Output
// //   010  |  000    // do nothing

// //  Input | Output
// //   011  |  110
// within { X(input[0]); }
// apply {
//     use ancilla = Qubit();
//     CCNOT(input[1], input[2], ancilla);
//     // we can measure the ancilla as it does not influence the states
//     if M(ancilla) == One {
//         // input is |111> so due to the within condition, so make output |110>
//         LeftShiftBy1(input, output);
//     }
//     Reset(ancilla);
// }

// //  Input | Output
// //   100  |  000    // do nothing

// // when first and last input qubits are 1, the output's middle qubit is 1
// //  Input | Output
// //   101  |  110
// within { X(input[1]); }
// apply {
//     use ancilla = Qubit();
//     CCNOT(input[0], input[2], ancilla);
//     if M(ancilla) == One {
//         // input is temporarily |111> due to the within condition
//         // left shift to make output |110>
//         LeftShiftBy1(input, output);
//         // ApplyToEach(X, output[0..1]);
//     }
//     Reset(ancilla);
// }

// //  Input | Output
// //   110  |  101
// within { X(input[2]); }
// apply {
//     use ancilla = Qubit();
//     CCNOT(input[0], input[1], ancilla);
//     if M(ancilla) == One {
//         LeftShiftBy1(input, output);
//         X(output[2]);
//         // X(output[0]);
//     }
//     Reset(ancilla);
// }

// //  Input | Output
// //   111  |  010
// // use 2 of 3 qubits to determine if ancilla should be activated
// use ancilla = Qubit();
// Controlled X(input[0..2], ancilla); // if input is |111>, ancilla will be 1
// if M(ancilla) == One {
//     // could do it just an X(output[1]) but
//     // in the spirit of the assignment, doing the shift functions
//     // |111> -> |011>
//     // C01_RightShiftBy1(input, output);
//     // // |011> -> |001>
//     // C01_RightShiftBy1(output, output);
//     // // |001> -> |010>
//     // LeftShiftBy1(output, output);
//     X(output[1]);
// }
// Reset(ancilla);

// // DumpMachine();

// // commented out the right and left shift functions as they are not needed
// // the shift functions also assume that the output is |000> at the start
// // so I can't feed in the output from the previous operation