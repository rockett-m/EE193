// Quantum Software Development
// Lab 1: Setting up the Development Environment
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 1/31.

namespace MITRE.QSD.L01 {

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
        // fail "Not implemented.";

        // measure the qubit's initial state
        let initial = M(target);

        // log the initial state to the console
        Message($"The qubit is in the {initial} state.");

        // if the qubit is in the |0> state, flip it to |1>
        if (initial == Zero) {
            // tell the user what we're doing
            Message("Flipping the qubit from |0> to the |1> state.");
            // apply the X gate to flip the qubit from |0> to |1>
            X(target);
        } else {
            // should not happen but let the user know
            Message("The qubit is already in the |1> state.");
        }

        // measure the qubit's final state
        let final = M(target);
        // log the final state to the console
        Message($"The qubit is in the {final} state.");

    }

    /// # Summary
    /// In this exercise, you are given two qubits. Both of them are in the |0>
    /// state. Using the single-qubit gates, turn them into the |+> state and
    /// |-> state respectively. Recall the |+> state is 1/√2(|0> + |1>) and the
    /// |-> state is 1/√2(|0> - |1>).
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
        fail "Not implemented.";
    }
}
