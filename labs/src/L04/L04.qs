// Quantum Software Development
// Lab 4: Quantum Communication & Quantum Error Correction
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 2/21.
// Note the section marked "CHALLENGE PROBLEMS" is optional.
// 5% extra credit is awarded for each challenge problem attempted;
// 10% for each implemented correctly.

namespace MITRE.QSD.L04 {

    open MITRE.QSD.Tests.L03;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// In this exercise, you will take on the role of the "sender" in the
    /// superdense coding protocol. You will encode a classical message into a
    /// pair of entangled qubits. The system has already entangled the two
    /// qubits together into the 1/√2(|00> + |11>) state and sent one of the
    /// qubits to the remote receiver. You are given a classical buffer with
    /// two bits in it, and the other remaining qubit. Your goal is to encode
    /// both of the classical bits into the entangled qubit pair using only
    /// single-qubit gates on the provided "sender" qubit.
    ///
    /// # Input
    /// ## buffer
    /// An array of two classical bits, where false represents 0, and true
    /// represents 1.
    ///
    /// ## pairA
    /// A qubit that is entangled with another qubit in the state
    /// 1/√2(|00> + |11>).
    operation E01_SuperdenseEncode (buffer : Bool[], pairA : Qubit) : Unit {
        // TODO
        // H, X already applied (default for engtangled qubits) |phi+> state
        // not is the same as checking == false
        if (not buffer[0] and not buffer[1]) {
            // | phi +> state
        } elif (not buffer[0] and buffer[1]) {
            // | psi +> state
            X(pairA);
        } elif (buffer[0] and not buffer[1]) {
            // | phi -> state
            Z(pairA);
        } elif (buffer[0] and buffer[1]) {
            // | psi -> state
            X(pairA); Z(pairA);
        }
    }


    /// # Summary
    /// In this exercise, you will take on the role of the "receiver" in the
    /// superdense coding protocol. The sender has sent a pair of entangled
    /// qubits to you and encoded two bits of classical data in them. The
    /// system has received the two qubits, and has presented them here for
    /// you to process. The state of the qubits is unknown, but it should be
    /// in one of the states that you created with your encoding operation
    /// above. Your goal is to recover the two classical bits that are encoded
    /// in the qubits, and return them in a classical buffer.
    ///
    /// # Input
    /// ## pairA
    /// One of the qubits in the entangled pair.
    ///
    /// ## pairB
    /// The other qubit in the entangled pair.
    ///
    /// # Output
    /// A classical bit array containing the two bits that were encoded in the
    /// entangled pair. Use false for 0 and true for 1.
    operation E02_SuperdenseDecode (pairA : Qubit, pairB : Qubit) : Bool[] {
        // TODO
        CNOT(pairA, pairB); H(pairA);
        // assign measurements Zero to false and One to true
        let measurementA = M(pairA) == Zero ? false | true;
        let measurementB = M(pairB) == Zero ? false | true;
        // picks 1 of 4 states (FF, FT, TF, TT) and returns the corresponding bits
        return [measurementA, measurementB]; 
    }


    /// # Summary
    /// In this exercise, you will take on the role of the first party in the
    /// BB84 protocol. (This is the QKD scheme discussed in lecture.) To make
    /// the operation easier to test, the random bits used in the protocol are
    /// given. Your goal is to encode A's public and secret bits into a qubit
    /// and determine whether the secret bit can be used or must be thrown away
    /// based on B's public bit.
    ///
    /// # Input
    /// ## aPublic
    /// The random bit you generated that will be shared with the other party.
    ///
    /// ## aSecret
    /// The random bit you generated that will not be shared directly with the
    /// other party, but may or may not be used as a shared secret based on the
    /// value of bPublic.
    ///
    /// ## bPublic
    /// The random bit generated by the other party and shared with you.
    ///
    /// ## qubit
    /// The qubit used to encode aPublic and aSecret.
    ///
    /// # Output
    /// A Boolean value that is true if the secret bit can be used and false if
    /// it must be thrown away.
    ///
    /// # Remarks
    /// In a real implementation of the protocol, bPublic would not be shared
    /// until after the qubit is measured.
    operation E03_BB84PartyA (
        aPublic : Bool,
        aSecret : Bool,
        bPublic : Bool,
        qubit: Qubit
    ) : Bool {
        // TODO
        // we simulate what happens when aSecret and or aPublic are true
        // they act as control bits for the X and H gates
        // if they are true then we modify the qubit with the corresponding gate
        if (aSecret) {
            X(qubit);
        }
        if (aPublic) {
            H(qubit);
        }
        // return true if secret but can be used, false if not
        // if aPublic and bPublic are the same, return true, else false
        return (aPublic == bPublic) ? true | false;        
    }


    /// # Summary
    /// In this exercise, you will take on the role of the second party in the
    /// BB84 protocol. Your goal is to attempt to decode A's secret bit and
    /// determine whether the it can be used or must be thrown away based on
    /// A's public bit.
    ///
    /// # Input
    /// ## aPublic
    /// The random bit generated by the other party and shared with you.
    ///
    /// ## bPublic
    /// The random bit you generated that will be shared with the other party.
    ///
    /// ## qubit
    /// The qubit you will attempt to decode.
    ///
    /// # Output
    /// A tuple of two Boolean values. The first value is true or false based
    /// on whether the secret bit you decoded is a 1 or 0. The second value is
    /// true if the secret bit can be used and false if it must be thrown away.
    operation E04_BB84PartyB (
        aPublic : Bool,
        bPublic : Bool,
        qubit: Qubit
    ) : (Bool, Bool) {
        // TODO
        // aPublic is used as a control bit for the H gate so apply if true
        if (aPublic) {
            H(qubit);
        }
        let secret = M(qubit) == One ? true | false;
        let usable = (aPublic == bPublic) ? true | false;

        return (secret, usable);
    }


    /// # Summary
    /// In this exercise, you are provided with an original qubit in an
    /// unknown state a|0> + b|1>. You are also provided with two blank
    /// qubits, both of which are in the |0> state. Your goal is to construct
    /// a "logical qubit" from these three qubits that acts like a single
    /// qubit, but can protect against bit-flip errors on any one of the three
    /// actual qubits.
    ///
    /// To construct the logical qubit, put the three qubits into the
    /// entangled state a|000> + b|111>.
    ///
    /// # Input
    /// ## original
    /// A qubit that you want to protect from bit flips. It will be in the
    /// state a|0> + b|1>.
    ///
    /// ## spares
    /// A register of two spare qubits that you can use to add error
    /// correction to the original qubit. Both are in the |0> state.
    operation E05_BitFlipEncode (
        original : Qubit,
        spares : Qubit[]
    ) : Unit is Adj {
        // Note the "Unit is Adj" - this is special Q# syntax that lets the
        // compiler automatically generate the adjoint (inverse) version of
        // this operation, so it can just be run backwards to decode the
        // logical qubit back into the original three unentangled qubits.

        // TODO
        // goal is to have majority consensus on the state of the qubits
        // we assume only 1 qubit will be flipped if any (so 2/3 or 3/3 qubits indicate state)

        // entangle the 3 qubits
        CNOT(original, spares[0]);
        CNOT(original, spares[1]);
    }


    /// # Summary
    /// In this exercise, you are provided with a logical qubit, represented
    /// by an error-protected register that was encoded with your Exercise 1
    /// implementation. Your goal is to perform a syndrome measurement on the
    /// register. This should consist of two parity checks (a parity check is
    /// an operation to see whether or not two qubits have the same state).
    /// The first parity check should be between qubits 0 and 1, and the 
    /// second check should be between qubits 0 and 2.
    ///
    /// # Input
    /// ## register
    /// A three-qubit register representing a single error-protected logical
    /// qubit. Its state is unknown, and one of the qubits may have suffered
    /// a bit flip error.
    ///
    /// # Output
    /// An array of two measurement results. The first result should be the
    /// measurement of the parity check on qubits 0 and 1, and the second
    /// result should be the measurement of the parity check on qubits 0 and
    /// 2. If both qubits in a parity check have the same state, the resulting
    /// bit should be Zero. If the two qubits have different states (meaning
    /// one of the two qubits was flipped), the result should be One.
    operation E06_BitFlipSyndrome (register : Qubit[]) : Result[] {
        // Hint: You will need to allocate an ancilla qubit for this. You can
        // do it with only one ancilla qubit, but you can allocate two if it
        // makes things easier. Don't forget to reset the qubits you allocate
        // back to the |0> state!

        // TODO
        // allocate ancilla qubits for the parity checks
        use ancilla1 = Qubit();
        use ancilla2 = Qubit();

        // entangle the ancilla qubits with the register qubits
        CNOT(register[0], ancilla1);
        CNOT(register[1], ancilla1);

        CNOT(register[0], ancilla2);
        CNOT(register[2], ancilla2);

        // syndrome measurement
        let parityCheck1 = M(ancilla1) == Zero ? Zero | One;
        let parityCheck2 = M(ancilla2) == Zero ? Zero | One;

        // reset ancilla qubits
        Reset(ancilla1); Reset(ancilla2);

        return [parityCheck1, parityCheck2];
    }


    /// # Summary
    /// In this exercise, you are provided with a logical qubit encoded with
    /// your Exercise 1 implementation and a syndrome measurement array
    /// produced by your Exercise 2 implementation. Your goal is to interpret
    /// the syndrome measurement to find which qubit in the error-corrected
    /// register suffered a bit-flip error (if any), and to correct it by
    /// flipping it back to the proper state.
    ///
    /// # Input
    /// ## register
    /// A three-qubit register representing a single error-protected logical
    /// qubit. Its state is unknown, and one of the qubits may have suffered
    /// a bit flip error.
    ///
    /// ## syndromeMeasurement
    /// An array of two measurement results that represent parity checks. The
    /// first one represents a parity check between qubit 0 and qubit 1; if
    /// both qubits have the same parity, the result will be 0, and if they
    /// have opposite parity, the result will be One. The second result
    /// corresponds to a parity check between qubit 0 and qubit 2.
    operation E07_BitFlipCorrection (
        register : Qubit[],
        syndromeMeasurement : Result[]
    ) : Unit {
        // Tip: you can use the Message() operation to print a debug message
        // out to the console. You might want to consider printing the index
        // of the qubit you identified as broken to help with debugging.

        // TODO
        if (syndromeMeasurement[0] == Zero and syndromeMeasurement[1] == Zero) {
            // no error
        } elif (syndromeMeasurement[0] == Zero and syndromeMeasurement[1] == One) {
            // qubit 2 bit flip error
            X(register[2]);
        } elif (syndromeMeasurement[0] == One and syndromeMeasurement[1] == Zero) {
            // qubit 1 bit flip error
            X(register[1]);
        } elif (syndromeMeasurement[0] == One and syndromeMeasurement[1] == One) {
            // qubit 0 bit flip error
            X(register[0]);
        }
    }


    //////////////////////////////////
    /// === CHALLENGE PROBLEMS === ///
    //////////////////////////////////


    /// # Summary
    /// In this exercise, you are provided with an original qubit in an
    /// unknown state a|0> + b|1>. You are also provided with 6 blank qubits,
    /// all of which are in the |0> state. Your goal is to construct a
    /// "logical qubit" from these 7 qubits that acts like a single qubit, but
    /// can protect against a single bit-flip error and a single phase-flip
    /// error on any of the actual qubits. The bit-flip and phase-flip may be
    /// on different qubits.
    ///
    /// # Input
    /// ## original
    /// A qubit that you want to protect from bit flips. It will be in the
    /// state a|0> + b|1>.
    ///
    /// ## spares
    /// A register of 6 spare qubits that you can use to add error correction
    /// to the original qubit. All of them are in the |0> state.
    operation C01_SteaneEncode (
        original : Qubit,
        spares : Qubit[]
    ) : Unit is Adj {
        // TODO
        ApplyToEachA(H, spares[3..5]);
        // the _ means substitute in each from beyond comma during loop
        ApplyToEachA(CNOT(original, _), spares[0..1]);
        ApplyToEachA(CNOT(spares[5], _), [original, spares[0], spares[2]]);
        ApplyToEachA(CNOT(spares[4], _), [original, spares[1], spares[2]]);
        ApplyToEachA(CNOT(spares[3], _), spares[0..2]);
    }


    /// # Summary
    /// In this exercise, you are provided with a logical qubit, represented
    /// by an error-protected register that was encoded with your Exercise 4
    /// implementation. Your goal is to perform a bit-flip syndrome
    /// measurement on the register, to determine if any of the bits have been
    /// flipped.
    ///
    /// # Input
    /// ## register
    /// A 7-qubit register representing a single error-protected logical
    /// qubit. Its state  is unknown, and it may have suffered a bit-flip
    /// and/or a phase-flip error.
    ///
    /// # Output
    /// An array of the 3 syndrome measurement results that the Steane code
    /// produces.
    operation C02_SteaneBitSyndrome (register : Qubit[]) : Result[] {
        // TODO
        use qubits =  Qubit[6];

        for i in [0,2,4,6] {
            CNOT(register[i], qubits[0]);
        }
        for i in [1,2,5,6] {
            CNOT(register[i], qubits[1]);
        }
        for i in 3..6 {
            CNOT(register[i], qubits[2]);
        }
        for i in 3..5 {
            H(qubits[i]);
        }
        for i in [0,2,4,6] {
            CNOT(qubits[3], register[i]);
        }
        for i in [1,2,5,6] {
            CNOT(qubits[4], register[i]);
        }
        for i in 3..6 {
            CNOT(qubits[5], register[i]);
        }
        for i in 3..5 {
            H(qubits[i]);
        }

        let syndrome = [M(qubits[2]) == Zero ? Zero | One, M(qubits[1]) == Zero ? Zero | One, M(qubits[0]) == Zero ? Zero | One];
        ResetAll(qubits);
        return syndrome;
    }


    /// # Summary
    /// In this exercise, you are provided with a logical qubit, represented
    /// by an error-protected register that was encoded with your Exercise 4
    /// implementation. Your goal is to perform a phase-flip syndrome
    /// measurement on the register, to determine if any of the qubits have
    /// suffered a phase-flip error.
    ///
    /// # Input
    /// ## register
    /// A 7-qubit register representing a single error-protected logical
    /// qubit. Its state is unknown, and it may have suffered a bit-flip
    /// and/or a phase-flip error.
    ///
    /// # Output
    /// An array of the 3 syndrome measurement results that the Steane code
    /// produces.
    operation C03_SteanePhaseSyndrome (register : Qubit[]) : Result[] {
        // TODO
        fail "Not implemented.";
    }


    /// # Summary
    /// In this exercise, you are provided with the 3-result array of syndrome
    /// measurements provided by the bit-flip or phase-flip measurement
    /// operations. Your goal is to determine the index of the broken qubit
    /// (if any) based on these measurements.
    ///
    /// As a reminder, for Steane's code, the following table shows the
    /// relationship between the syndrome measurements and the index of the
    /// broken qubit:
    /// -----------------------
    /// 000 = No error
    /// 001 = Error or qubit 0
    /// 010 = Error on qubit 1
    /// 011 = Error on qubit 2
    /// 100 = Error on qubit 3
    /// 101 = Error on qubit 4
    /// 110 = Error on qubit 5
    /// 111 = Error on qubit 6
    /// -----------------------
    ///
    /// # Input
    /// ## syndrome
    /// An array of the 3 syndrome measurement results from the bit-flip or
    /// phase-flip measurement operations. These will come from your
    /// implementations of Exercise 5 and Exercise 6.
    ///
    /// # Output
    /// An Int identifying the index of the broken qubit, based on the
    /// syndrome measurements. If none of the qubits are broken, you should
    /// return -1.
    ///
    /// # Remarks
    /// This is a "function" instead of an "operation" because it's a purely
    /// classical method. It doesn't have any quantum parts to it, just lots
    /// of regular old classical math and logic.
    function C04_SyndromeToIndex (syndrome : Result[]) : Int {
        // TODO
        fail "Not implemented.";
    }


    /// # Summary
    /// In this exercise, you are given a logical qubit represented by an
    /// error-protected register of 7 physical qubits. This register was
    /// produced by your implementation of Exercise 4. It is in an unknown
    /// state, but one of its qubits may or may not have suffered a bit-flip
    /// error, and another qubit may or may not have suffered a phase-flip
    /// error. Your goal is to use your implementations of Exercises 5, 6, and
    /// 7 to detect and correct the bit-flip and/or phase-flip errors in the
    /// register.
    ///
    /// # Input
    /// ## register
    /// A 7-qubit register representing a single error-protected logical
    /// qubit. Its state is unknown, and it may have suffered a bit-flip
    /// and/or a phase-flip error.
    ///
    /// # Remarks
    /// This test may take a lot longer to run than you're used to, because it
    /// tests every possible combination of bit and phase flips on a whole
    /// bunch of different original qubit states. Don't worry if it doesn't
    /// immediately finish!
    operation C05_SteaneCorrection (register : Qubit[]) : Unit {
        // TODO
        fail "Not implemented.";
    }
}
