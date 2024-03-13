// Quantum Software Development
// Lab 5: Toy Algorithms
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 3/13.

namespace MITRE.QSD.L05 {

    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;


    /// # Summary
    /// This oracle always "returns" zero, so it never phase-flips the target
    /// qubit.
    ///
    /// # Input
    /// ## input
    /// The input register to evaluate.
    ///
    /// ## target
    /// The target qubit to phase-flip.
    operation AlwaysZero (input : Qubit[], target : Qubit) : Unit {
        // This literally does nothing, no matter what the input is.
    }


    /// # Summary
    /// This oracle always "returns" one, so it always phase-flips the target
    /// qubit.
    ///
    /// # Input
    /// ## input
    /// The input register to evaluate.
    ///
    /// ## target
    /// The target qubit to phase-flip.
    operation AlwaysOne (input : Qubit[], target : Qubit) : Unit {
        // All this does is phase-flip the target. The input is useless here.
        Z(target);
    }


    /// # Summary
    /// In this exercise, you are given a register with an unknown number of
    /// qubits, in an unknown state, and a target qubit in the |1> state.
    /// Your goal is to construct an oracle that will flip the phase of the
    /// target qubit if the register bit value contains an odd number of 1's,
    /// and leave the target qubit alone if it contains an even number of 1's.
    ///
    /// For example, if the register was in the state |10101>, you would
    /// phase-flip the target qubit because there was an odd number of |1>
    /// qubits. If the register was in the state |01010>, you would leave the
    /// target qubit alone.
    ///
    /// # Input
    /// ## input
    /// A register of qubits in an unknown state. It could be in an arbitrary
    /// superposition.
    ///
    /// ## target
    /// A target qubit to phase-flip if the oracle's conditions are met. It
    /// will be in the |1> state to start; you must put it in the -|1> state
    /// if the input register bit value contains an odd number of 1's.
    operation E01_PhaseFlipOnOdd1s (input : Qubit[], target : Qubit) : Unit {
        // Note: Oracles aren't allowed to collapse the superposition of the
        // input register, so you aren't allowed to do any qubit measurements.
        // You'll need to use some kind of controlled gate that will give the
        // correct result, no matter what the input is.
        //
        // Hint: If you phase-flip the target qubit twice, it will have the
        // same effect as not flipping it at all. Phase-flipping it three
        // times will have the same effect as only flipping it once, etc.

        // TODO
        // target will get phase flip if 1 or 3 of the qubits are == 1
        for i in 0..Length(input) - 1 {
            Controlled Z([input[i]], target);
        }
    }


    /// # Summary
    /// In this exercise, you are given a register with an unknown number of
    /// qubits, in an unknown state, and a target qubit in the |1> state. You
    /// are also given two indices of qubits in the register. Your goal is to
    /// construct an oracle that will phase-flip the target qubit if the two
    /// qubits with the given indices have different parity. That is, if both
    /// qubits have the same bit value, you should leave the target qubit
    /// alone; if the qubits have opposite bit values, you should phase-flip
    /// the target.
    ///
    /// # Input
    /// ## firstIndex
    /// The index in the register of the first qubit to use in the parity
    /// check.
    ///
    /// ## secondIndex
    /// The index in the register of the second qubit to use in the parity
    /// check.
    ///
    /// ## input
    /// A register of qubits in an unknown state. It could be in an arbitrary
    /// superposition.
    ///
    /// ## target
    /// A target qubit to phase-flip if the oracle's conditions are met. It
    /// will be in the |1> state to start; you must put it in the -|1> state
    /// if the two qubits in the register at the given indices have opposite
    /// parity.
    operation E02_PhaseFlipOnOddParity (
        firstIndex : Int,
        secondIndex : Int,
        input : Qubit[],
        target : Qubit
    ) : Unit {
        // TODO
        X(input[firstIndex]); // 01 -> 11 will activate the control
        Controlled Z([input[firstIndex], input[secondIndex]], target);
        X(input[firstIndex]); // 11 -> 01 undo

        X(input[secondIndex]); // 10 -> 11 will activate the control
        Controlled Z([input[firstIndex], input[secondIndex]], target);
        X(input[secondIndex]); // 11 -> 10 undo
    }


    /// # Summary
    /// In this exercise, you will implement the Deutsch-Jozsa algorithm. You
    /// are given an oracle, which is an operation that takes in a qubit
    /// register and a target qubit that will be phase-flipped if the
    /// register meets the oracle's condition. The register must be in the
    /// |+...+> state, and the target qubit must be in the |1> state. Your
    /// goal is to prepare the input register and target qubit, run the oracle,
    /// and use the resulting state of the register to determine whether the
    /// oracle represents a constant function or a balanced function.
    ///
    /// # Input
    /// ## inputLength
    /// The number of qubits that the oracle expects the input register to
    /// contain. You must allocate a register with this many qubits to provide
    /// to the oracle.
    ///
    /// ## oracle
    /// A quantum operation that represents some function. It will take in an
    /// input register (that must be in the |+...+> state) and a target qubit
    /// (that must be in the |1> state). It will phase-flip the target qubit
    /// for each term in the register's superposition that meets its criteria,
    /// with the effect of that term being phase-flipped due to phase kickback.
    ///
    /// # Output
    /// You should return true if the function is constant, or false if it is
    /// balanced.
    operation E03_DeutschJozsa (
        inputLength : Int,
        oracle : ((Qubit[], Qubit) => Unit)
    ) : Bool {
        // Tip: you can allocate multiple different things at once using tuple
        // notation. For example:
        //      use (input, target) = (Qubit[inputLength], Qubit())
        // will allocate a qubit register called "input", and a single qubit
        // called "target".
        //
        // Note: Remember to put the input and target in the correct states
        // before running the oracle!

        // TODO
        DumpMachine();
        use (input, target) = (Qubit[inputLength], Qubit());

        // Setup: Put the input register in the |+...+> state, make the target qubit |1>
        ApplyToEach(H, input);
        X(target);

        // Run the oracle
        // E01_PhaseFlipOnOdd1s(input, target);

        // 3 input qubits then 3 controlled Z gates
        // for i in 0..Length(input) - 1 {
        //     Controlled Z([input[i]], target);
        // }

        // AlwaysZero(input, target);
        // AlwaysZero(input, target);
        // E01_PhaseFlipOnOdd1s(input, target);
        // E02_PhaseFlipOnOddParity(0, 1, input, target);

        for i in 0..Length(input) - 1 {
            E02_PhaseFlipOnOddParity(i, (i + 1) % Length(input), input, target);
            // Controlled Z([input[i]], target);
        }

        // E01_PhaseFlipOnOdd1s(input, target);
        // E02_PhaseFlipOnOddParity(0, 1, input, target);

        // for i in 0..Length(input) - 1 {
        //     // AlwaysOne([input[i]], target);
            
        //     let first_index = i;
        //     let second_index = i + 1 % Length(input);
        //     E02_PhaseFlipOnOddParity(first_index, second_index, input, target);

        //     // Controlled Z([input[i]], target);
        // }



        // Controlled Z([input[0]], target);
        // Controlled Z([input[1]], target);
        // ApplyToEach(oracle(_, target), input);

        DumpMachine();

        // Put the input register back in the |0...0> state
        ApplyToEach(H, input);

        DumpMachine();
        
        // measure all qubits in the input register
        // let result = MeasureAllZ(input);
        // ResetAll(input);
        // return result == Zero;


        // Measure the input register (all zeros - function is constant, otherwise balanced)
        for i in 0..Length(input) - 1 {
            let result = M(input[i]);
            // function is balanced if this occurs
            if (result == One) { 
                // reset qubit
                Reset(input[i]);
                return false;
            } else {
                // reset qubit if it is not balanced
                Reset(input[i]);
            }
        }
        // return true if the function is constant (balanced would not make it this far)
        // ResetAll(input);
        return true;
    }


    /// # Summary
    /// In this exercise, you are given a register with an unknown number of
    /// qubits, in an unknown state, and a target qubit in the |1> state.
    /// Your goal is to construct an oracle that will flip the phase of the
    /// target qubit if the bitwise (mod-2) dot product of the register value
    /// with the bitstring 's' is 1.
    ///
    /// For example, if s=110 and the register was in the state |101>, you would
    /// phase-flip the target qubit because 110 * 101 = 1 + 0 + 0 (mod 2) = 1.
    /// If the register was in the state |111>, you would leave the target qubit
    /// alone because 110 * 111 = 1 + 1 + 0 (mod 2) = 0.
    ///
    /// # Input
    /// ## s
    /// A Boolean array representing the first argument of the dot product.
    ///
    /// ## input
    /// A register of qubits in an unknown state. It could be in an arbitrary
    /// superposition.
    ///
    /// ## target
    /// A target qubit to phase-flip if the oracle's conditions are met. It
    /// will be in the |1> state to start.
    operation E04_BitwiseDotProduct (
        s : Bool[],
        input : Qubit[],
        target : Qubit
    ) : Unit {
        fail "Not implemented.";
    }


    /// # Summary
    /// In this exercise, you will implement the Bernstein-Vazirani algorithm.
    /// You are given an oracle, which is an operation that takes in a qubit
    /// register and a target qubit that will be phase-flipped based on the
    /// bitwise dot product of the register value and the secret bitstring s.
    /// Your goal is to prepare the input register and target qubit, run the
    /// oracle, and use the resulting state of the register to find s.
    ///
    /// # Input
    /// ## inputLength
    /// The number of qubits that the oracle expects the input register to
    /// contain. You must allocate a register with this many qubits to provide
    /// to the oracle.
    ///
    /// ## oracle
    /// A B-V phase-flip oracle with a secret bitstring s. Takes an input
    /// register and target qubit.
    ///
    /// # Output
    /// Return s as Boolean array.
    operation E05_BernsteinVazirani (
        inputLength : Int,
        oracle : ((Qubit[], Qubit) => Unit)
    ) : Bool[] {
        fail "Not implemented.";
    }
}
