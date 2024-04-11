// Quantum Software Development
// Lab 8: Quantum Fourier Transform
// Copyright 2024 The MITRE Corporation. All Rights Reserved.

namespace MITRE.QSD.L08 {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;


    /// # Summary
    /// In this exercise, you must implement the quantum Fourier transform
    /// circuit. The operation should be performed in-place, meaning the
    /// time-domain output should be in the same order as the frequency-domain
    /// input, not reversed.
    ///
    /// # Input
    /// ## register
    /// A qubit register with unknown length in an unknown state. Assume big
    /// endian ordering.
    operation E01_QFT (register : Qubit[]) : Unit is Adj + Ctl {
        // Hint: There are two operations you may want to use here:
        //  1. Your implementation of register reversal in Lab 3, Exercise 2.
        //  2. The Microsoft.Quantum.Intrinsic.R1Frac() gate.

        // TODO
        // Hint: There are two operations you may want to use here:
        //  1. Your implementation of register reversal in Lab 3, Exercise 2.
        //  2. The Microsoft.Quantum.Intrinsic.R1Frac() gate.

        // TODO
        let n = Length(register);
        let idx_final_reg = n - 1;

        for idx in 0..idx_final_reg {
            // Apply the Hadamard gate to every qubit in the register
            H(register[idx]);

            // don't apply R gates when there is only one qubit left
            for k in 2..(idx_final_reg - idx + 1) {
                let idx_tgt = idx + (k - 1);
                Controlled R1Frac([register[idx]], (2, k, register[idx_tgt]));
            }
        }

        // Reverse the register
        mutable num_qubits = n;
        // clean midpoint either way now
        if (n % 2 == 1) { let num_qubits = n - 1; }
        // index up to halfway (leave middle alone odd since no need to swap)
        let iter_bounds = (num_qubits / 2) - 1;
        for left in 0 .. iter_bounds {
            let right = num_qubits - 1 - left;
            // swap the qubits
            SWAP(register[left], register[right]);
        }
    }




    /// # Summary
    /// In this exercise, you are given a quantum register with a single cosine
    /// wave encoded into the amplitudes of each term in the superposition.
    ///
    /// For example, the first sample of the wave will be the amplitude of the
    /// |0> term, the second sample of the wave will be the amplitude of the
    /// |1> term, the third will be the amplitude of the |2> term, and so on.
    ///
    /// Your goal is to estimate the frequency of these samples.
    ///
    /// # Input
    /// ## register
    /// The register which contains the samples of the sine wave in the
    /// amplitudes of its terms. Assume big endian ordering.
    ///
    /// ## sampleRate
    /// The number of samples per second that were used to collect the
    /// original samples. You will need this to retrieve the correct
    /// frequency.
    ///
    /// # Output
    /// The frequency of the cosine wave.
    ///
    /// # Remarks
    /// When using the DFT to analyze the frequency components of a purely real
    /// signal, typically the second half of the output is thrown away, since
    /// these represent frequencies too fast to show up in the time domain.
    /// Here, we can't just "throw away" a part of the output, so if we measure
    /// a value above N/2, it will need to be mirrored about N/2 to recover the
    /// actual frequency of the input sine wave. For more info, see:
    /// https://en.wikipedia.org/wiki/Nyquist_frequency
    operation E02_EstimateFrequency (
        register : Qubit[],
        sampleRate : Double
    ) : Double {
        // TODO
        // Hint: You may want to use the Microsoft.Quantum.Math.ArcTan2() function.
        let n = Length(register);
        let N = 2^Length(register);

        // apply the Quantum Fourier Transform
        E01_QFT(register);
        // Message($"sampleRate: {sampleRate}; n: {n}; N: {N}");

        // make empty array to hold results
        mutable results = [Zero, size=n];

        // print out the results for debugging
        for idx in 0..n-1 {
            set results w/= idx <- M(register[idx]);
        }
        // Message($"results: {results}");
        ResetAll(register);

        // get the decimal value of the results
        mutable idx_decimal = 0;

        for idx in 0..n-1 {
            if results[idx] == One {
                set idx_decimal = idx_decimal + 2^(n - idx - 1);
            }
        }

        // if idx is greater than N/2, mirror the results
        // so if binary results array to decimal translation / N > 0.5
        // then mirror the results as in (N - decimal) / N
        // multiplied by sample rate to get the frequency
        // if we have n=4, N=16, and idx_decimal=9; fraction = 9/16 = 0.5625
        // so we mirror the results as in 16 - 9 = 7; fraction = 7/16 = 0.4375
        // as our frequency has to be less than N/2
        mutable fraction = IntAsDouble(idx_decimal) / IntAsDouble(N);
        if (fraction > 0.50) {
            set idx_decimal = N / 2 - (idx_decimal - (N / 2));
            set fraction = IntAsDouble(idx_decimal) / IntAsDouble(N);
        }
        let freq = sampleRate * fraction;
        return freq;
    }
}
