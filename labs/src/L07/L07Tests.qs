// QSD Lab 7 Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace MITRE.QSD.Tests.L07 {

    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Math;

    open MITRE.QSD.L07;


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
        let testCases = [
            [false, true, true],
            [true, false, true, true],
            [true, true, false, true, false],
            [false, false, true, true, false, true],
            [true, true, true, true, false, true, true],
            [true, true, true, true, true, true, true, true],
            [true, false, false, true, true, false, false, true, true],
            [true, false, true, true, false, true, false, true, true, false]
        ];

        for testCase in testCases {
            let length = Length(testCase);
            use qubits = Qubit[length];

            mutable randomState = [];
            for i in 0 .. length - 1 {
                set randomState += [DrawRandomInt(0, 1) == 1];
                if randomState[i] {
                    X(qubits[i]);
                }
            }

            E01_XOR(testCase, qubits);

            for i in 0 .. length - 1 {
                let result = ResultAsBool(M(qubits[i]));
                Fact(
                    result == (testCase[i] != randomState[i]),
                    $"Incorrect result for {testCase[i]} XOR {randomState[i]}"
                );
            }

            ResetAll(qubits);
        }

        // Ensure qubits are not being measured
        use qubit = Qubit();
        let rotation = GenerateRandomRotation();
        ApplyRotation(rotation, qubit);

        E01_XOR([true], [qubit]);

        X(qubit);
        Adjoint ApplyRotation(rotation, qubit);

        Fact(CheckZero(qubit), "Qubit in unnexpected state.");
    }


    operation E02Test () : Unit {
        for numQubits in 3 .. 8 {
            use (qubits, target) = (Qubit[numQubits], Qubit());
            ApplyToEach(H, qubits + [target]);

            E02_CheckIfAllZeros(qubits, target);

            H(target);

            mutable isAllZero = true;
            for qubit in qubits {
                if M(qubit) == One {
                    set isAllZero = false;
                }
            }

            Fact(
                (M(target) == One) == isAllZero,
                "AllZeros test failed"
            );

            ResetAll(qubits + [target]);
        }

        // Ensure qubits are not being measured
        use (qubit, target) = (Qubit(), Qubit());
        let rotation = GenerateRandomRotation();
        ApplyRotation(rotation, qubit);
        H(target);

        E02_CheckIfAllZeros([qubit], target);

        X(qubit);
        Controlled Z([qubit], target);
        X(qubit);
        Adjoint ApplyRotation(rotation, qubit);
        H(target);

        Fact(CheckAllZero([qubit] + [target]), "Qubits in unnexpected state");
    }


    operation E03Test () : Unit {
        for numQubits in 3 .. 8 {
            mutable original = [];
            mutable key = [];
            mutable encrypted = [];
            for j in 0 .. numQubits - 1 {
                set original += [DrawRandomInt(0, 1) == 1];
                set key += [DrawRandomInt(0, 1) == 1];
                set encrypted += [original[j] != key[j]];
            }

            use (qubits, target) = (Qubit[numQubits], Qubit());
            ApplyToEach(H, qubits + [target]);

            E03_CheckKey(original, encrypted, qubits, target);

            H(target);

            mutable foundCorrectKey = true;
            for j in 0 .. numQubits - 1 {
                if (M(qubits[j]) == One) != key[j] {
                    set foundCorrectKey = false;
                }
            }

            Fact(
                (M(target) == One) == foundCorrectKey,
                "CheckKey test failed"
            );

            ResetAll(qubits + [target]);
        }

        // Ensure qubits are not being measured
        use (qubit, target) = (Qubit(), Qubit());
        let rotation = GenerateRandomRotation();
        ApplyRotation(rotation, qubit);
        H(target);

        E03_CheckKey([true], [true], [qubit], target);

        X(qubit);
        Controlled Z([qubit], target);
        X(qubit);
        Adjoint ApplyRotation(rotation, qubit);
        H(target);

        Fact(CheckAllZero([qubit] + [target]), "Qubits in unnexpected state");
    }


    operation E04Test () : Unit {
        for numQubits in 3 .. 8 {
            mutable original = [];
            mutable key = [];
            mutable encrypted = [];
            for j in 0 .. numQubits - 1 {
                set original += [DrawRandomInt(0, 1) == 1];
                set key += [DrawRandomInt(0, 1) == 1];
                set encrypted += [original[j] != key[j]];
            }

            use (qubits, target) = (Qubit[numQubits], Qubit());
            ApplyToEach(H, qubits);
            X(target);

            E04_GroverIteration(
                E03_CheckKey(original, encrypted, _, _),
                qubits,
                target
            );

            ApplyToEach(H, qubits);
            E02_CheckIfAllZeros(qubits, target);
            ApplyToEach(H, qubits);

            E03_CheckKey(original, encrypted, qubits, target);
            X(target);
            ApplyToEach(H, qubits);

            Fact(
                CheckAllZero(qubits + [target]),
                "Qubits in unnexpected state"
            );
        }
    }


    operation BoolArrayAsString (boolArray : Bool[]) : String {
        mutable str = "";
        for i in 0 .. Length(boolArray) - 1 {
            set str += boolArray[i] ? "1" | "0";
            if i % 8 == 7 {
                set str += " ";
            }
        }
        return str;
    }


    operation E05Test () : Unit {
        let MAX_TRIALS = 5;
        for numQubits in 5 .. 9 {
            mutable original = [];
            mutable key = [];
            mutable encrypted = [];
            for j in 0 .. numQubits - 1 {
                set original += [DrawRandomInt(0, 1) == 1];
                set key += [DrawRandomInt(0, 1) == 1];
                set encrypted += [original[j] != key[j]];
            }

            Message($"Running Grover search on {numQubits} qubits.");
            Message($"Original = {BoolArrayAsString(original)}");
            Message($"Encrypted = {BoolArrayAsString(encrypted)}");

            mutable foundCorrectKey = false;
            mutable trial = 1;
            repeat {
                if trial > MAX_TRIALS {
                    fail "Max trials reached";
                }

                let result = E05_GroverSearch(
                    E03_CheckKey(original, encrypted, _, _),
                    numQubits
                );

                Message($"Search returned {BoolArrayAsString(result)}");

                set foundCorrectKey = true;
                for j in 0 .. numQubits - 1 {
                    if result[j] != key[j] {
                        set foundCorrectKey = false;
                    }
                }
                if (foundCorrectKey) {
                    Message("Got the right key!");
                } else {
                    Message("Incorrect key, trying again...");
                }

                set trial += 1;
            }
            until foundCorrectKey == true;
        }
    }
}
