// QSD Lab 2 Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace MITRE.QSD.Tests.L02 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;

    open MITRE.QSD.L02;


    operation E01Test () : Unit {
        for numQubits in 3 .. 10 {
            use qubits = Qubit[numQubits];

            E01_YRotations(qubits);

            for index in 0 .. numQubits - 1 {
                Ry(PI() * IntAsDouble(index) / -12.0, qubits[index]);
            }

            Fact(
                CheckAllZero(qubits),
                "At least one target qubit not prepared correctly."
            );
        }
    }


    operation E02Test () : Unit {
        for i in 0 .. 4 {
            mutable states = [];
            use qubits = Qubit[5];
            for j in 0 .. 4 {
                set states += [DrawRandomInt(0, 1)];
                if states[j] == 1 {
                    X(qubits[j]);
                }
            }

            let results = E02_MeasureQubits(qubits);

            Fact(states == results, "Results did not match encoded states.");
            ResetAll(qubits);
        }
    }


    operation E03Test () : Unit {
        for numQubits in 1 .. 8 {
            use qubits = Qubit[numQubits];

            E03_PrepareUniform(qubits);

            ApplyToEach(H, qubits);

            Fact(CheckAllZero(qubits), "State not prepared correctly.");
        }
    }


    operation E04Test () : Unit {
        for numQubits in 1 .. 8 {
            use qubits = Qubit[numQubits];

            ApplyToEach(H, qubits);

            E04_PhaseFlipOddTerms(qubits);

            Z(qubits[numQubits - 1]);
            ApplyToEach(H, qubits);

            Fact(CheckAllZero(qubits), "State not prepared correctly.");
        }
    }
}