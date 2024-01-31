// QSD Lab 1 Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace MITRE.QSD.Tests.L01 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    open MITRE.QSD.L01;


    operation E01Test () : Unit {
        use target = Qubit();

        E01_BitFlip(target);

        X(target);

        Fact(
            CheckZero(target),
            "Target not correctly bit-flipped."
        );
    }


    operation E02Test () : Unit {
        use targets = Qubit[2];

        E02_PrepPlusMinus(targets[0], targets[1]);

        H(targets[0]);
        H(targets[1]);
        X(targets[1]);

        Fact(
            CheckAllZero(targets),
            "At least one target qubit not prepared correctly."
        );
    }
}
