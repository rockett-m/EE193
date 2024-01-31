// QSD Lab 3 Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace MITRE.QSD.Tests.L03 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;

    open MITRE.QSD.L03;


    operation GenerateRandomRotation () : Double[] {
        return [
            DrawRandomDouble(0.0, PI()),
            DrawRandomDouble(0.0, 2.0 * PI())
        ];
    }

    operation ApplyRotation (rotation : Double[], target: Qubit) : Unit
    is Adj + Ctl {
        Rx(rotation[0], target);
        Rz(rotation[1], target);
    }


    operation E01Test () : Unit {
        for i in 0 .. 4 {
            use qubits = Qubit[2];
            let rotations = [
                GenerateRandomRotation(),
                GenerateRandomRotation()
            ];

            ApplyRotation(rotations[0], qubits[0]);
            ApplyRotation(rotations[1], qubits[1]);

            E01_SwapAmplitues(qubits[0], qubits[1]);

            Adjoint ApplyRotation(rotations[0], qubits[1]);
            Adjoint ApplyRotation(rotations[1], qubits[0]);

            Fact(CheckAllZero(qubits), "Amplitudes not swapped correctly");
        }
    }


    operation E02Test () : Unit {
        for numQubits in 3 .. 8 {
            use register = Qubit[numQubits];
            mutable rotations = [];
            for index in 0 .. numQubits - 1 {
                set rotations += [GenerateRandomRotation()];
                ApplyRotation(rotations[index], register[index]);
            }

            E02_ReverseRegister(register);

            for index in 0 .. numQubits - 1 {
                Adjoint ApplyRotation(
                    rotations[numQubits - index - 1],
                    register[index]
                );
            }

            Fact(CheckAllZero(register), "Register not reversed correctly");
        }
    }


    operation E03Test () : Unit {
        use qubits = Qubit[8];
        let registers = [
            [qubits[0], qubits[1]],
            [qubits[2], qubits[3]],
            [qubits[4], qubits[5]],
            [qubits[6], qubits[7]]
        ];

        E03_PrepareBellStates(registers);

        for register in registers {
            CNOT(register[0], register[1]);
            H(register[0]);
        }

        // now, register 0 should be |00>,
        //      register 1 should be |10>,
        //      register 2 should be |01>, and
        //      register 3 should be |11>
        X(registers[1][0]);
        X(registers[2][1]);
        X(registers[3][0]);
        X(registers[3][1]);

        Fact(
            CheckAllZero(qubits),
            "At least one state not prepared correctly."
        );
    }


    operation E04Test () : Unit {
        for numQubits in 2 .. 10 {
            use register = Qubit[numQubits];

            E04_PrepareGHZState(register);

            for index in 1 .. numQubits - 1 {
                CNOT(register[0], register[index]);
            }
            H(register[0]);

            Fact(CheckAllZero(register), "State not prepared correctly.");
        }
    }


    operation E05Test () : Unit {
        use register = Qubit[4];

        E05_CombineMultipleGates(register);

        Z(register[2]);
        X(register[3]);
        CNOT(register[2], register[3]);
        H(register[2]);
        X(register[1]);

        Fact(CheckAllZero(register), "State not prepared correctly.");
    }


    operation E06Test () : Unit {
        use register = Qubit[2];

        E06_PrepareNonUniform(register);

        Controlled H([register[0]], register[1]);
        H(register[0]);

        Fact(CheckAllZero(register), "State not prepared correctly.");
    }


    operation E07Test () : Unit {
        use (register, target) = (Qubit[3], Qubit());

        E07_EntangleTarget(register, target);

        ApplyToEach(X, register[0 .. 1]);
        Controlled X(register, target);
        ApplyToEach(X, register[0 .. 1]);
        ApplyToEach(H, register);

        Fact(
            CheckAllZero(register + [target]),
            "State not prepared correctly."
        );
    }


    operation E08Test () : Unit {
        use register = Qubit[3];

        E08_PrepareComplexState(register);

        ApplyToEach(X, register[1 .. 2]);
        use ancilla = Qubit() {
            X(ancilla);
            Controlled Z(register, ancilla);
            X(ancilla);
        }
        ApplyToEach(X, register[1 .. 2]);
        CNOT(register[1], register[2]);
        Controlled H([register[0]], register[1]);
        H(register[0]);

        Fact(CheckAllZero(register), "State not prepared correctly.");
    }


    operation C01Test () : Unit {
        use register = Qubit[2];

        C01_ThreeTermsEqualAmp(register);

        X(register[0]);
        Controlled H([register[0]], register[1]);

        let theta = ArcCos(Sqrt(1.0 / 3.0));
        Ry(-2.0 * theta, register[0]);

        Fact(CheckAllZero(register), "State not prepared correctly.");
    }


    operation C02Test () : Unit {
        use register = Qubit[3];

        C02_PrepareWState(register);

        X(register[0]);
        CNOT(register[1], register[2]);
        CNOT(register[0], register[2]);
        Controlled H([register[0]], register[1]);

        let theta = ArcCos(Sqrt(1.0 / 3.0));
        Ry(-2.0 * theta, register[0]);

        Fact(CheckAllZero(register), "State not prepared correctly.");
    }


    operation C03Test () : Unit {
        use register = Qubit[3];

        C03_EncodeCosine(register);

        ApplyToEach(Z, register[0 .. 1]);
        H(register[0]);
        Controlled H([register[2]], register[1]);
        H(register[2]);

        Fact(CheckAllZero(register), "State not prepared correctly.");
    }


    operation C04Test () : Unit {
        use register = Qubit[3];

        C04_EncodeSine(register);

        Z(register[0]);
        H(register[0]);
        X(register[1]);
        Controlled H([register[2]], register[1]);
        H(register[2]);

        Fact(CheckAllZero(register), "State not prepared correctly.");
    }
}
