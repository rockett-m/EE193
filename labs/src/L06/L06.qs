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
        Controlled X(input[0..2], output[0]);
        Controlled X(input[0..2], output[2]);
        ApplyToEach(X, input[0..2]);

        //   001  |  010
        ApplyToEach(X, input[0..1]);
        Controlled X(input[0..2], output[1]);
        ApplyToEach(X, input[0..1]);

        //   010  |  000
        // do nothing

        //   011  |  110
        X(input[0]);
        Controlled X(input[0..2], output[0]);
        X(input[0]);

        //   100  |  000
        // do nothing

        //   101  |  110
        X(input[1]);
        Controlled X(input[0..2], output[0]);
        X(input[1]);

        //   110  |  101
        X(input[2]);
        Controlled X(input[0..2], output[0]);
        Controlled X(input[0..2], output[2]);
        X(input[2]);

        //   111  |  010
        Controlled X(input[0..2], output[1]);
    }
}
