// Quantum Software Development
// Lab 1: Setting up the Development Environment
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 1/31.

namespace MITRE.QSD.L01 {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    /// # Summary
    /// In this exercise, you are given a single qubit which is in the |0>
    /// state. Your objective is to flip the qubit. Use the single-qubit
    /// quantum gates that Q# provides to transform it into the |1> state.
    ///
    /// # Input
    /// ## target
    /// The qubit you need to flip. It will be in the |0> state initially.
    ///
    /// # Remarks
    /// This investigates how to apply quantum gates to qubits in Q#.
    operation E01_BitFlip (target: Qubit) : Unit {
        // TODO
        if not CheckZero(target) {
            Message("[Error] The qubit is not in the |0> state.");
        } else {
            Message("The qubit is in the |0> state.");
            X(target);
            if not CheckZero(target) {
                Message("The qubit was switched to the |1> state.");
            }
        }
    }

    /// # Summary
    /// In this exercise, you are given two qubits. Both of them are in the |0>
    /// state. Using the single-qubit gates, turn them into the |+> state and
    /// |-> state respectively. Recall the 
    /// |+> state is 1/√2(|0> + |1>)
    /// |-> state is 1/√2(|0> - |1>)
    ///
    /// # Input
    /// ## targetA
    /// Turn this qubit from |0> to |+>.
    ///
    /// ## targetB
    /// Turn this qubit from |0> to |->.
    ///
    /// # Remarks
    /// This investigates how to prepare the |+> and |-> states.
    operation E02_PrepPlusMinus (targetA : Qubit, targetB : Qubit) : Unit {
        // TODO

        // Turn this qubit from |0> to |+>.
        H(targetA);

        // Turn this qubit from |0> to |->
        X(targetB);
        H(targetB);
    }
}

// all of this code breaks the test \/ (measurement changes results)
// operation E02_PrepPlusMinus (targetA : Qubit, targetB : Qubit) : Unit {
// let initialA = M(targetA);
// let initialB = M(targetB);

// Message($"The qubit A is in the {initialA} state.");
// Message($"The qubit B is in the {initialB} state.");

// if CheckZero(targetA) {
//     Message("Turning qubit A from |0> to |+> ");
//     H(targetA);
// } else {
//     Message("[Error] The qubit A is not in the |0> state.");
// }

// if CheckZero(targetB) {
//     Message("Turning qubit B from |0> to |-> ");
//     X(targetB);
//     H(targetB);
// } else {
//     Message("[Error] The qubit B is not in the |0> state.");
// }

// // debug
// let finalA = M(targetA);
// let finalB = M(targetB);

// Message($"The qubit A is in the {finalA} state.");
// Message($"The qubit B is in the {finalB} state.");
//
// all of this code breaks the test /\