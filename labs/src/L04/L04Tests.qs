// QSD Lab 4 Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace MITRE.QSD.Tests.L04 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;

    open MITRE.QSD.L04;


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
        let buffers = [
            [false, false],
            [false, true],
            [true, false],
            [true, true]
        ];

        for i in 1 .. 10 {
            for buffer in buffers {
                use qubits = Qubit[2];
                H(qubits[0]);
                CNOT(qubits[0], qubits[1]);

                E01_SuperdenseEncode(buffer, qubits[0]);

                CNOT(qubits[0], qubits[1]);
                H(qubits[0]);

                Fact(
                    ResultAsBool(M(qubits[0])) == buffer[0],
                    "First qubit is incorrect."
                );
                Fact(
                    ResultAsBool(M(qubits[1])) == buffer[1],
                    "Second qubit is incorrect."
                );

                ResetAll(qubits);
            }
        }
    }


    operation E02Test () : Unit {
        let buffers = [
            [false, false],
            [false, true],
            [true, false],
            [true, true]
        ];

        for i in 1 .. 10 {
            for buffer in buffers {
                use qubits = Qubit[2];
                H(qubits[0]);
                CNOT(qubits[0], qubits[1]);
                if buffer[1] {
                    X(qubits[0]);
                }
                if buffer[0] {
                    Z(qubits[0]);
                }

                let result = E02_SuperdenseDecode(qubits[0], qubits[1]);

                Fact(
                    result == buffer,
                    "Decoded value is incorrect."
                );

                ResetAll(qubits);
            }
        }
    }


    operation E03Test () : Unit {
        for i in 0 .. 7 {
            let aPublic = (i / 4 == 1);
            let aSecret = (i / 2 % 2 == 1);
            let bPublic = (i % 2 == 1);
            use qubit = Qubit();
            let result = E03_BB84PartyA(aPublic, aSecret, bPublic, qubit);

            if aPublic { H(qubit); }
            if aSecret { X(qubit); }

            Fact(
                result == (aPublic == bPublic),
                "Keep/reject value is incorrect."
            );

            Fact(CheckZero(qubit), "Qubit in unexpected state.");
        }
    }


    operation E04Test () : Unit {
        for i in 0 .. 7 {
            let aPublic = (i / 4 == 1);
            let aSecret = (i / 2 % 2 == 1);
            let bPublic = (i % 2 == 1);
            use qubit = Qubit();
            if aSecret { X(qubit); }
            if aPublic { H(qubit); }

            let (bSecret, keep) = E04_BB84PartyB(aPublic, bPublic, qubit);

            Fact(
                keep == (aPublic == bPublic),
                "Keep/reject value is incorrect."
            );

            if (keep) {
                Fact(
                    aSecret == bSecret,
                    "Secret bits do not match."
                );
            }

            Reset(qubit);
        }
    }


    operation E05Test () : Unit {
        for i in 1 .. 25 {
            use (original, spares) = (Qubit(), Qubit[2]);
            let rotation = GenerateRandomRotation();
            ApplyRotation(rotation, original);

            E05_BitFlipEncode(original, spares);

            CNOT(original, spares[0]);
            CNOT(original, spares[1]);
            Adjoint ApplyRotation(rotation, original);

            Fact(
                CheckAllZero([original] + spares),
                "Incorrect encoding implementation."
            );
        }
    }


    operation E06Test () : Unit {
        for i in 1 .. 10 {
            for brokenQubitIndex in -1 .. 3 {
                use register = Qubit[3];
                let rotation = GenerateRandomRotation();
                ApplyRotation(rotation, register[0]);
                E05_BitFlipEncode(register[0], register[1 .. 2]);

                // no error
                if (brokenQubitIndex == -1) {
                    mutable syndrome = E06_BitFlipSyndrome(register);
                    if syndrome[0] != Zero or syndrome[1] != Zero {
                        fail "Incorrect syndrome measurement. "
                           + "It should have been [Zero, Zero] but it was"
                           + $"[{syndrome[0]}, {syndrome[1]}";
                    }
                }

                // first qubit is flipped
                elif (brokenQubitIndex == 0) {
                    X(register[0]);
                    mutable syndrome = E06_BitFlipSyndrome(register);
                    if syndrome[0] != One or syndrome[1] != One {
                        fail "Incorrect syndrome measurement. "
                           + "It should have been [One, One] but it was"
                           + $"[{syndrome[0]}, {syndrome[1]}";
                    }
                }

                // second qubit is flipped
                elif (brokenQubitIndex == 1) {
                    X(register[1]);
                    mutable syndrome = E06_BitFlipSyndrome(register);
                    if syndrome[0] != One or syndrome[1] != Zero {
                        fail "Incorrect syndrome measurement. "
                           + "It should have been [One, Zero] but it was"
                           + $"[{syndrome[0]}, {syndrome[1]}";
                    }
                }

                // third qubit is flipped
                elif (brokenQubitIndex == 1) {
                    X(register[2]);
                    mutable syndrome = E06_BitFlipSyndrome(register);
                    if syndrome[0] != Zero or syndrome[1] != One {
                        fail "Incorrect syndrome measurement. "
                           + "It should have been [Zero, One] but it was"
                           + $"[{syndrome[0]}, {syndrome[1]}";
                    }
                }

                ResetAll(register);
            }
        }
    }


    operation E07Test () : Unit {
        for i in 1 .. 10 {
            for brokenQubitIndex in -1 .. 2 {
                use register = Qubit[3];
                let rotation = GenerateRandomRotation();
                ApplyRotation(rotation, register[0]);
                E05_BitFlipEncode(register[0], register[1 .. 2]);

                if brokenQubitIndex >= 0 {
                    X(register[brokenQubitIndex]);
                }

                let syndrome = E06_BitFlipSyndrome(register);

                E07_BitFlipCorrection(register, syndrome);

                Adjoint E05_BitFlipEncode(register[0], register[1 .. 2]);
                Adjoint ApplyRotation(rotation, register[0]);

                Fact(
                    CheckAllZero(register),
                    "Incorrect bit flip correction implementation."
                );
            }
        }
    }


    operation C01Test () : Unit {
        use (original, spares) = (Qubit(), Qubit[6]);

        for i in 1 .. 10 {
            let rotation = GenerateRandomRotation();
            ApplyRotation(rotation, original);

            C01_SteaneEncode(original, spares);

            ApplyToEach(CNOT(spares[3], _), spares[0 .. 2]);
            ApplyToEach(CNOT(spares[4], _), [original] + spares[1 .. 2]);
            ApplyToEach(CNOT(spares[5], _), [original, spares[0], spares[2]]);
            ApplyToEach(CNOT(original, _), spares[0 .. 1]);
            ApplyToEach(H, spares[3 .. 5]);

            Adjoint ApplyRotation(rotation, original);

            Fact(
                CheckAllZero([original] + spares),
                "Incorrect encoding implementation."
            );
        }
    }


    operation C02Test () : Unit {
        use qubits =  Qubit[7];

        for i in 1 .. 10 {
            for brokenIndex in -1 .. 6 {
                let rotation = GenerateRandomRotation();
                ApplyRotation(rotation, qubits[0]);

                C01_SteaneEncode(qubits[0], qubits[1 .. 6]);

                if brokenIndex >= 0 {
                    X(qubits[brokenIndex]);
                }

                let syndrome = C02_SteaneBitSyndrome(qubits);

                if ((brokenIndex + 1) &&& 0b100) == 0b100 {
                    Fact(
                        syndrome[0] == One,
                        "Bit-flip syndrome measurment 0 is incorrect"
                    );
                }
                if ((brokenIndex + 1) &&& 0b010) == 0b010 {
                    Fact(
                        syndrome[1] == One,
                        "Bit-flip syndrome measurement 1 is incorrect"
                    );
                }
                if ((brokenIndex + 1) &&& 0b001) == 0b001 {
                    Fact(
                        syndrome[2] == One,
                        "Bit-flip syndrome measurement 2 is incorrect"
                    );
                }

                ResetAll(qubits);
            }
        }
    }


    operation C03Test () : Unit {
        use qubits = Qubit[7];

        for i in 1 .. 10 {
            for brokenIndex in -1 .. 6 {
                let rotation = GenerateRandomRotation();
                ApplyRotation(rotation, qubits[0]);

                C01_SteaneEncode(qubits[0], qubits[1 .. 6]);

                if brokenIndex >= 0 {
                    Z(qubits[brokenIndex]);
                }

                let syndrome = C03_SteanePhaseSyndrome(qubits);

                if ((brokenIndex + 1) &&& 0b100) == 0b100 {
                    Fact(
                        syndrome[0] == One,
                        "Phase-flip syndrome measurment 0 is incorrect"
                    );
                }
                if ((brokenIndex + 1) &&& 0b010) == 0b010 {
                    Fact(
                        syndrome[1] == One,
                        "Phase-flip syndrome measurement 1 is incorrect"
                    );
                }
                if ((brokenIndex + 1) &&& 0b001) == 0b001 {
                    Fact(
                        syndrome[2] == One,
                        "Phase-flip syndrome measurement 2 is incorrect"
                    );
                }

                ResetAll(qubits);
            }
        }
    }


    operation C04Test () : Unit {
        for brokenIndex in -1 .. 6 {
            let syndrome = [
                ((brokenIndex + 1) &&& 0b100) == 0b100 ? One | Zero,
                ((brokenIndex + 1) &&& 0b010) == 0b010 ? One | Zero,
                ((brokenIndex + 1) &&& 0b001) == 0b001 ? One | Zero
            ];
            Fact(
                C04_SyndromeToIndex(syndrome) == brokenIndex,
                $"Incorrect broken index for syndrome {syndrome}"
            );
        }
    }


    operation C05Test () : Unit {
        use qubits = Qubit[7];

        for i in 1 .. 10 {
            for bitFlipIndex in -1 .. 6 {
                for phaseFlipIndex in -1 .. 6 {
                    let rotation = GenerateRandomRotation();
                    ApplyRotation(rotation, qubits[0]);

                    C01_SteaneEncode(qubits[0], qubits[1 .. 6]);

                    if bitFlipIndex >= 0 {
                        X(qubits[bitFlipIndex]);
                    }

                    if phaseFlipIndex >= 0 {
                        Z(qubits[phaseFlipIndex]);
                    }

                    C05_SteaneCorrection(qubits);

                    Adjoint C01_SteaneEncode(qubits[0], qubits[1 .. 6]);
                    Adjoint ApplyRotation(rotation, qubits[0]);

                    Fact(
                        CheckAllZero(qubits),
                        "Incorrect Steane correction implementation."
                    );
                }
            }
        }
    }
}
