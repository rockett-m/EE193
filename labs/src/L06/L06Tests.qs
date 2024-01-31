// QSD Lab 6 Q# Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.


namespace MITRE.QSD.Tests.L06 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;

    open MITRE.QSD.L06;


    operation E01Test () : Unit {
        for numQubits in 3 .. 10 {
            mutable randomInput = [];
            for i in 1 .. numQubits {
                set randomInput += [DrawRandomInt(0, 1) == 1];
            }

            let shiftOutput = E01_RunOpAsClassicalFunc(
                LeftShiftBy1,
                randomInput
            );
            let expected = randomInput[1...] + [false];
            Fact(
                shiftOutput == expected,
                "Incorrect output for LeftShiftBy1 operation"
            );
        }
    }


    operation E02TestHelper (inputSize : Int) : Bool[] {
        return E02_SimonQSubroutine(LeftShiftBy1, inputSize);
    }


    operation C01TestHelper (inputSize : Int) : Bool[] {
        return E02_SimonQSubroutine(C01_RightShiftBy1, inputSize);
    }


    operation C02TestHelper (inputSize : Int) : Bool[] {
        return E02_SimonQSubroutine(C02_SimonBB, inputSize);
    }
}
