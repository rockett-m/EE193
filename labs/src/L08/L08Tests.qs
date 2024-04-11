// QSD Lab 8 Tests
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace MITRE.QSD.Tests.L08 {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;

    open MITRE.QSD.L08;


    operation BigEndianQFT(register : Qubit[]) : Unit is Adj + Ctl {
        ApplyQFT(Reversed(register));
        SwapReverseRegister(register);
    }


    operation E01Test () : Unit {
        for i in 1 .. 5 {
            Fact(
                CheckOperationsAreEqual(i, E01_QFT, BigEndianQFT),
                "Incorrect QFT implementation."
            );
        }
    }


    operation E02Test () : Unit {
        let TOLERANCE = 0.001;

        for numQubits in 2 .. 8 {
            use register = Qubit[numQubits];

            // randomly pick a frequency bin below Nyquist
            let freqBin = DrawRandomInt(1, 2 ^ (numQubits - 1) - 1);

            // 1/√2(|0> + |2 ^ (numQubits - 1)>) (little endian)
            H(Tail(register));

            // 1/√2(|0> + |2 ^ (numQubits - 1) + freqBin>)
            Controlled ApplyXorInPlace(
                [Tail(register)],
                (freqBin, register[0 .. Length(register) - 2])
            );

            // 1/√2(|freqBin> + |2 ^ (numQubits - 1)>)
            X(Tail(register));

            // 1/√2(|freqBin> + |2 ^ numQubits - freqBin>)
            Controlled ApplyXorInPlace(
                [Tail(register)],
                (
                    2 ^ (numQubits - 1) - freqBin,
                    register[0 .. Length(register) - 2]
                )
            );

            ApplyQFT(register);

            let sampleRate = DrawRandomDouble(1.0, 100.0);
            let estimatedFreq = E02_EstimateFrequency(register, sampleRate);
            let actualFreq = IntAsDouble(freqBin) * sampleRate / IntAsDouble(2 ^ numQubits);

            // print all these values for debugging
            // Message($"numQubits: {numQubits}");
            // Message($"freqBin: {freqBin}");
            // Message($"sampleRate: {sampleRate}");
            // Message($"estimatedFreq: {estimatedFreq}");
            // Message($"actualFreq: {actualFreq}");

            Fact(
                estimatedFreq < (actualFreq + TOLERANCE) and estimatedFreq > (actualFreq - TOLERANCE),
                "Incorrect frequency."
            )
        }
    }
}
