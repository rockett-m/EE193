// Quantum Software Development
// Lab 8: Quantum Fourier Transform
// Copyright 2024 The MITRE Corporation. All Rights Reserved.

namespace MITRE.QSD.L08 {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;


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
        fail "Not implemented.";
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
        fail "Not implemented.";
    }
}
