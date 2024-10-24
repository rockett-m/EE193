// Quantum Software Development
// Lab 2: Working with Qubit Registers
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 2/7.

namespace MITRE.QSD.L02 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;


    /// # Summary
    /// In this exercise, you have been given an array of qubits. The length
    /// of the array is a secret; you'll have to figure it out using Q#. The
    /// goal is to rotate each qubit around the Y axis by 15° (π/12 radians),
    /// multiplied by its index in the array.
    ///
    /// For example: if the array had 3 qubits, you would need to leave the
    /// first one alone (index 0), rotate the next one by 15° (π/12 radians),
    /// and rotate the last one by 30° (2π/12 = π/6 radians).
    ///
    /// # Input
    /// ## qubits
    /// The array of qubits you need to rotate.
    ///
    /// # Remarks
    /// This investigates how to work with arrays and for loops in Q#, and how
    /// to use the arbitrary rotation gates.
    operation E01_YRotations (qubits : Qubit[]) : Unit {
        // Tip: You can get the value of π with the function PI().
        // Tip: You can use the IntAsDouble() function to cast an integer to
        // a double for floating-point arithmetic. Q# won't let you do
        // arithmetic between Doubles and Ints directly.

        // TODO
        // get the value of the pi constant and the length of the qubit array
        let pi = PI();

        // loop through the qubits and apply the rotation
        for i in 0 .. Length(qubits) - 1 {
            // measure the qubit before the rotation
            // let qubitBefore = M(qubits[i]);
            // calculate the rotation amount
            let rotateAmount = IntAsDouble(i) * 15.0 * (pi / 180.0);
            // rotate about the Y axis
            Ry(rotateAmount, qubits[i]);
            // measure the qubit after the rotation
            // let qubitAfter = M(qubits[i]);

            // debug
            // Message("The qubit number " + i + "  before rotation is: " + qubitBefore);
            // Message("The qubit number " + i + "  after rotation is: " + qubitAfter);
        }
    }


    /// # Summary
    /// In this exercise, you have been given an array of qubits, the length of
    /// which is unknown again. Your goal is to measure each of the qubits, and
    /// construct an array of Ints based on the measurement results.
    ///
    /// # Input
    /// ## qubits
    /// The qubits to measure. Each of them is in an unknown state.
    ///
    /// # Output
    /// An array of Ints that has the same length as the input qubit array.
    /// Each element should be the measurement result of the corresponding
    /// qubit in the input array. For example: if you measure the first qubit
    /// to be Zero, then the first element of this array should be 0. If you
    /// measure the third qubit to be One, then the third element of this array
    /// should be 1.
    ///
    /// # Remarks
    /// This investigates how to measure qubits, work with those measurements,
    /// and how to return things in Q# operations. It also involves conditional
    /// statements.
    operation E02_MeasureQubits (qubits : Qubit[]) : Int[] {
        // Tip: You can either create the Int array with the full length
        // directly and update each of its values with the apply-and-replace
        // operator, or append each Int to the array as you go. Use whichever
        // method you prefer.
        // open Microsoft.Quantum.Convert;
        // open Microsoft.Quantum.Diagnostics;
        // TODO
        mutable output = [0, size=Length(qubits)];

        for i in 0 .. Length(qubits) - 1 {
            let measurement = M(qubits[i]);
            // result of measurement can be a 0 or 1 but add logic to get integer
            let resultAsInt = measurement == Zero ? 0 | 1;
            // assign measurement to corresponding qubit index in resultant array
            set output w/= i <- resultAsInt;
        }
        return output;
    }

    /// # Summary
    /// In this exercise, you are given a register of unknown length, which
    /// will be in the state |0...0>. Your goal is to put it into the |+...+>
    /// state, which is a uniform superposition of all possible measurement
    /// outcomes. For example, if it had three qubits, you would have to put
    /// it into this state:
    ///
    ///     |+++> =                               1
    ///             ---------------------------------------------------------------
    ///            √8 (|000> + |001> + |010> + |011> + |100> + |101> + |110> + |111>)
    ///
    /// # Input
    /// ## register
    /// A register of unknown length. All of its qubits are in the |0> state,
    /// so the register's state is |0...0>.
    ///
    /// # Remarks
    /// This investigates how to construct uniform superpositions, where a
    /// register is in a combination of all possible measurement outcomes, and
    /// each superposition term has an equal amplitude to the others.
    operation E03_PrepareUniform (register : Qubit[]) : Unit {
        // TODO
        // loop through the qubits and apply the Hadamard gate
        for i in 0 .. Length(register) - 1 {
            // apply the Hadamard gate to get superposition
            H(register[i]);
        }
    }

    /// # Summary
    /// In this exercise, you are given a register of unknown length, which
    /// will be in the state |+...+>. (This is the uniform superposition
    /// constructed in the previous exercise.) Your goal is to flip the phase
    /// of every odd-valued term in the superposition, preparing the state:
    ///
    ///                                 1
    ///             --------------------------------------------
    ///            √N (|0> - |1> + |2> - |3> + |4> - ... - |N-1>)
    ///
    /// Note that, in the above expression, N = 2^(Length(register))
    ///
    /// # Input
    /// ## register
    /// A register of unknown length. All of its qubits are in the |+> state,
    /// so the register's state is |+...+>.
    ///
    /// # Remarks
    /// This investigates how a single-qubit gate can affect a multi-qubit
    /// state and tests your understanding of using integers for register
    /// values.
    operation E04_PhaseFlipOddTerms (register : Qubit[]) : Unit {
        // TODO
        Z(register[Length(register) - 1]);
    }
}


//     operation E04_PhaseFlipOddTerms (register : Qubit[]) : Unit {
// if there is a 1 in the last bit (odd), then flip the phase
// +|000>
// +|001> -> -|001>
// +|010>
// +|011> -> -|011>
// +|100>
// +|101> -> -|101>
// +|110>
// +|111> -> -|111>
// make N be 2^registerLength = 2^3 = 8 or 2^8 = 64 for example

// not needed - to flip phase of odd states we just apply Z gate to the last qubit
// for i in 0 .. registerLength - 1 {
//     // Message("$The qubit number {i}");
//     // print out the qubit number before rotation
//     // let measurement = M(register[i]);
//     // Message("The qubit number {i} before rotation is: {measurement}");

//     // detect odd indices
//     if (i % 2 == 1) {

//         Controlled Z(register[0..registerLength-2], register[registerLength-1]);
//         // Z gate does a 180 degree phase flip
//         // Z(register[i]);
//         Z(register[registerLength - 1]);
//     }
// }