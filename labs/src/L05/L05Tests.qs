// QSD Lab 5 Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace MITRE.QSD.Tests.L05 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Random;

    open MITRE.QSD.L05;


    operation E01Test () : Unit {
        for numQubits in 3 .. 8 {
            use (input, output) = (Qubit[numQubits], Qubit());
            ApplyToEach(H, input);
            X(output);

            E01_PhaseFlipOnOdd1s(input, output);

            for qubit in input {
              Controlled Z([qubit], output);
            }
            X(output);
            ApplyToEach(H, input);

            Fact(
                CheckAllZero(input + [output]),
                "Incorrect oracle implementation."
            );
        }
    }


    operation E02Test () : Unit {
        for i in 1 .. 10 {
            for numQubits in 3 .. 8 {
                use (input, output) = (Qubit[numQubits], Qubit());
                let firstIndex = DrawRandomInt(0, numQubits - 1);
                let temp = DrawRandomInt(0, numQubits - 2);
                let secondIndex = firstIndex != temp ? temp | temp + 1;

                ApplyToEach(H, input);
                X(output);

                E02_PhaseFlipOnOddParity(
                    firstIndex,
                    secondIndex,
                    input,
                    output
                );

                Controlled Z([input[firstIndex]], output);
                Controlled Z([input[secondIndex]], output);
                X(output);
                ApplyToEach(H, input);

                Fact(
                    CheckAllZero(input + [output]),
                    "Incorrect oracle implementation."
                );
            }
        }
    }


    operation E03Test () : Unit {
        for i in 0 .. 10 {
            for numQubits in 3 .. 8 {
                let firstIndex = DrawRandomInt(0, numQubits - 1);
                    let temp = DrawRandomInt(0, numQubits - 2);
                    let secondIndex = firstIndex != temp ? temp | temp + 1;

                if E03_DeutschJozsa(numQubits, AlwaysZero) == false {
                    fail "Incorrectly classified AlwaysZero as balanced.";
                }

                if E03_DeutschJozsa(numQubits, AlwaysOne) == false {
                    fail "Incorrectly classified AlwaysOne as balanced.";
                }

                if E03_DeutschJozsa(numQubits, E01_PhaseFlipOnOdd1s) == true {
                    fail "Incorrectly classified E01 as constant.";
                }

                if E03_DeutschJozsa(
                    numQubits,
                    E02_PhaseFlipOnOddParity(firstIndex, secondIndex, _, _)
                ) == true {
                    fail "Incorrectly classified E02 as constant.";
                }
            }
	    }
    }


    operation E04Test () : Unit {
        let sValues = [
            [true],
            [true, false, true],
            [true, true, false, false, true, true, true, false]
        ];

        for s in sValues {
            use (register, target) = (Qubit[Length(s)], Qubit());
            ApplyToEach(H, register);
            X(target);
            E04_BitwiseDotProduct(s, register, target);
            ApplyToEach(H, register);
            let measuredS = ResultArrayAsBoolArray(MeasureEachZ(register));
            Fact(
                s == measuredS,
                "Incorrect oracle implementation."
            );
            ResetAll(register + [target]);
        }
    }


    operation E05Test () : Unit {
        let sValues = [
            [true],
            [true, false, true],
            [true, true, false, false, true, true, true, false]
        ];

        for s in sValues {
            let measuredS = E05_BernsteinVazirani(
                Length(s),
                E04_BitwiseDotProduct(s, _, _)
            );
            Fact(
                s == measuredS,
                "Incorrect s value."
            );
        }
    }
}
