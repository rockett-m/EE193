// Quantum Software Development
// Lab 9: Shor's Factorization Algorithm
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 4/24.
//
// Note: Use little endian ordering when storing and retrieving integers from
// qubit registers in this lab.

namespace MITRE.QSD.L09 {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Unstable.Arithmetic;
    open Microsoft.Quantum.Diagnostics;
    open MITRE.QSD.L08;

    /// # Summary
    /// Performs modular in-place multiplication by a classical constant.
    ///
    /// # Description
    /// Given the classical constants `c` and `modulus`, and an input quantum
    /// register |𝑦⟩ in little-endian format, this operation computes
    /// `(c*y) % modulus` into |𝑦⟩.
    ///
    /// # Input
    /// ## modulus
    /// Modulus to use for modular multiplication
    /// ## c
    /// Constant by which to multiply |𝑦⟩
    /// ## y
    /// Quantum register of target
    ///
    /// # Remarks
    /// Taken from code sample in Q# playground.
    operation ModularMultiplyByConstant(modulus : Int, c : Int, y : Qubit[])
    : Unit is Adj + Ctl {
        use qs = Qubit[Length(y)];
        for idx in IndexRange(y) {
            let shiftedC = (c <<< idx) % modulus;
            Controlled ModularAddConstant(
                [y[idx]],
                (modulus, shiftedC, qs));
        }
        for idx in IndexRange(y) {
            SWAP(y[idx], qs[idx]);
        }
        let invC = InverseModI(c, modulus);
        for idx in IndexRange(y) {
            let shiftedC = (invC <<< idx) % modulus;
            Controlled ModularAddConstant(
                [y[idx]],
                (modulus, modulus - shiftedC, qs));
        }
    }


    /// # Summary
    /// Performs modular in-place addition of a classical constant into a
    /// quantum register.
    ///
    /// Given the classical constants `c` and `modulus`, and an input quantum
    /// register |𝑦⟩ in little-endian format, this operation computes
    /// `(y+c) % modulus` into |𝑦⟩.
    ///
    /// # Input
    /// ## modulus
    /// Modulus to use for modular addition
    /// ## c
    /// Constant to add to |𝑦⟩
    /// ## y
    /// Quantum register of target
    ///
    /// # Remarks
    /// Taken from code sample in Q# playground.
    operation ModularAddConstant(modulus : Int, c : Int, y : Qubit[])
    : Unit is Adj + Ctl {
        body (...) {
            Controlled ModularAddConstant([], (modulus, c, y));
        }
        controlled (ctrls, ...) {
            // We apply a custom strategy to control this operation instead of
            // letting the compiler create the controlled variant for us in
            // which the `Controlled` functor would be distributed over each
            // operation in the body.
            //
            // Here we can use some scratch memory to save ensure that at most
            // one control qubit is used for costly operations such as
            // `AddConstant` and `CompareGreaterThenOrEqualConstant`.
            if Length(ctrls) >= 2 {
                use control = Qubit();
                within {
                    Controlled X(ctrls, control);
                } apply {
                    Controlled ModularAddConstant([control], (modulus, c, y));
                }
            } else {
                use carry = Qubit();
                Controlled IncByI(ctrls, (c, y + [carry]));
                Controlled Adjoint IncByI(ctrls, (modulus, y + [carry]));
                Controlled IncByI([carry], (modulus, y));
                Controlled ApplyIfLessOrEqualL(ctrls, (X, IntAsBigInt(c), y, carry));
            }
        }
    }


    /// # Summary
    /// In this exercise, you must implement the quantum modular
    /// exponentiation function: |o> = a^|x> mod b.
    /// |x> and |o> are input and output registers respectively, and a and b
    /// are classical integers.
    ///
    /// # Input
    /// ## a
    /// The base power of the term being exponentiated.
    ///
    /// ## b
    /// The modulus for the function.
    ///
    /// ## input
    /// The register containing a superposition of all of the exponent values
    /// that the user wants to calculate; this superposition is arbitrary.
    ///
    /// ## output
    /// This register must contain the output |o> of the modular
    /// exponentiation function. It will start in the |0...0> state.
    operation E01_ModExp (
        a : Int,
        b : Int,
        input : Qubit[],
        output : Qubit[]
    ) : Unit {
        // Notes:
        //  - Use Microsoft.Quantum.Math.ExpModI() to calculate a modular
        //    exponent classically.
        //  - Use the ModularMultiplyByConstant operation above to multiply a
        //    qubit register by a constant under some modulus.

        // TODO
        let n = Length(input);

        // apply X gate to the last qubit of the output register (LSB)
        X(output[Length(output) - 1]);

        // Message($"Input length: {n}");
        // Message($"Output length: {Length(output)}");

        // iterate over input register in reverse order
        for idx_fwd in 0 .. n - 1 {
            let idx_rev = (n - 1) - idx_fwd;
            // c = A^(2^(n-i-1)) mod b
            let mod_exp = ExpModI(a, 2^idx_rev, b);
            // |O> = |O * c mod b>
            Controlled ModularMultiplyByConstant(
                [input[idx_fwd]],
                (b, mod_exp, output));
        }
    }


    /// # Summary
    /// In this exercise, you must implement the quantum subroutine of Shor's
    /// algorithm. You will be given a number to factor and some guess to a
    /// possible factor - both of which are integers.
    /// You must set up, execute, and measure the quantum circuit.
    /// You should return the fraction that was produced by measuring the
    /// result at the end of the subroutine, in the form of a tuple:
    /// the first value should be the number you measured, and the second
    /// value should be 2^n, where n is the number of qubits you use in your
    /// input register.
    ///
    /// # Input
    /// ## numberToFactor
    /// The number that the user wants to factor. This will become the modulus
    /// for the modular arithmetic used in the subroutine.
    ///
    /// ## guess
    /// The number that's being guessed as a possible factor. This will become
    /// the base of exponentiation for the modular arithmetic used in the
    /// subroutine.
    ///
    /// # Output
    /// A tuple representing the continued fraction approximation that the
    /// subroutine measured. The first value should be the numerator (the
    /// value that was measured from the qubits), and the second value should
    /// be the denominator (the total size of the input space, which is 2^n
    /// where n is the size of your input register).
    operation E02_FindApproxPeriod (
        numberToFactor : Int,
        guess : Int
    ) : (Int, Int) {
        // Hint: you can use the Microsoft.Quantum.Measurement.MeasureInteger()
        // function to measure a whole set of qubits and transform them into
        // their integer representation.

        // TODO
        let (modulus, base) = (numberToFactor, guess);

        // if we have perfect power of 2 like 2^6 = 64, keep it as is
        // otherwise, find the next power of 2 to represent the input space
        mutable n = Floor(Lg(IntAsDouble(modulus)));
        // mod 37 e.g. would be floor(log2(37)) = 5 but 2^5 = 32, 32 < 37 so we need 2^6
        if (2^n < modulus) { set n = n + 1; }
        // 2^n is the number of qubits needed to represent the input space
        let inputSpaceSize = 2^n;

        // create input and output registers with 2n and n qubits respectively
        use (inputReg, outputReg) = (Qubit[2*n], Qubit[n]);

        // apply Hadamard gate to the input register for uniform superposition
        ApplyToEachA(H, inputReg);

        // apply the quantum modular exponentiation function
        E01_ModExp(base, modulus, inputReg, outputReg);

        // apply the inverse quantum Fourier transform
        Adjoint E01_QFT(inputReg);

        // measure the input register
        let measured = MeasureInteger(inputReg);

        // reset qubits
        ResetAll(inputReg); ResetAll(outputReg);

        // return the measured value and the denominator (solution space size)
        return (measured, 2^inputSpaceSize);
    }


    /// # Summary
    /// In this exercise, you will be given an arbitrary numerator and
    /// denominator for a fraction, along with some threshold value for the
    /// denominator.
    /// Your goal is to return the largest convergent of the continued
    /// fraction that matches the provided number, with the condition that the
    /// denominator of your convergent must be less than the threshold value.
    ///
    /// # Input
    /// ## numerator
    /// The numerator of the original fraction
    ///
    /// ## denominator
    /// The denominator of the original fraction
    ///
    /// ## denominatorThreshold
    /// A threshold value for the denominator. The continued fraction
    /// convergent that you find must be less than this value. If it's higher,
    /// you must return the previous convergent.
    ///
    /// # Output
    /// A tuple representing the convergent that you found. The first element
    /// should be the numerator, and the second should be the denominator.
    function E03_FindPeriodCandidate (
        numerator : Int,
        denominator : Int,
        denominatorThreshold : Int
    ) : (Int, Int) {
        // TODO
        mutable (numer_test, denom_test) = (numerator, denominator);
        // base case: first two convergents are 0/1 and 1/0
        mutable convergent = (0, 1);

        // avoid division by zero
        mutable m = [0, 1];
        mutable d = [1, 0];
        // m_i = a_i * m_{i-1} + m_{i-2}
        // d_i = a_i * d_{i-1} + d_{i-2}

        mutable finish = false;

        // denominatorThreshold is the maximum value for the denominator
        for i in 2 .. denominatorThreshold {
            if not finish {
                let a_i = Floor(IntAsDouble(numer_test) / IntAsDouble(denom_test));
                let remainder = numer_test - (a_i * denom_test);

                // append new fraction to end of list
                set m += [a_i * m[1] + m[0]];
                set d += [a_i * d[1] + d[0]];

                // pop first element to keep list size of 3 [i-2, i-1, curr]
                set m = m[1 .. Length(m)-1];
                set d = d[1 .. Length(d)-1];

                let (_, highestDenom) = convergent;
                // new high convergent found
                if ((d[Length(d)-1] < denominatorThreshold) and (d[Length(d)-1] > highestDenom)) {
                    set convergent = (m[Length(m)-1], d[Length(d)-1]);
                    // Message($"Convergent: {convergent}");
                }

                if (remainder == 0) {
                    set finish = true;
                } else {
                    set numer_test = denom_test;
                    set denom_test = remainder;
                }
            }
        }
        return convergent;
    }


    /// # Summary
    /// In this exercise, you are given two integers - a number that you want
    /// to find the factors of, and an arbitrary guess as to one of the
    /// factors of the number. This guess was already checked to see if it was
    /// a factor of the number, so you know that it *isn't* a factor. It is
    /// guaranteed to be co-prime with numberToFactor.
    ///
    /// Your job is to find the period of the modular exponentation function
    /// using these two values as the arguments. That is, you must find the
    /// period of the equation y = guess^x mod numberToFactor.
    ///
    /// # Input
    /// ## numberToFactor
    /// The number that the user wants to find the factors for
    ///
    /// ## guess
    /// Some co-prime integer that is smaller than numberToFactor
    ///
    /// # Output
    /// The period of y = guess^x mod numberToFactor.
    operation E04_FindPeriod (numberToFactor : Int, guess : Int) : Int
    {
        // Note: you can't use while loops in operations in Q#.
        // You'll have to use a repeat loop if you want to run
        // something several times.

        // Hint: you can use the
        // Microsoft.Quantum.Math.GreatestCommonDivisorI()
        // function to calculate the GCD of two numbers.

        // TODO
        fail "Not implemented.";
        // Microsoft.Quantum.Math.GreatestCommonDivisorI()
    }


    /// # Summary
    /// In this exercise, you are given a number to find the factors of,
    /// a guess of a factor (which is guaranteed to be co-prime), and the
    /// period of the modular exponentiation function that you found in
    /// Exercise 4.
    ///
    /// Your goal is to use the period to find a factor of the number if
    /// possible.
    ///
    /// # Input
    /// ## numberToFactor
    /// The number to find a factor of
    ///
    /// ## guess
    /// A co-prime number that is *not* a factor
    ///
    /// ## period
    /// The period of the function y = guess^x mod numberToFactor.
    ///
    /// # Output
    /// - If you can find a factor, return that factor.
    /// - If the period is odd, return -1.
    /// - If the period doesn't work for factoring, return -2.
    function E05_FindFactor (
        numberToFactor : Int,
        guess : Int,
        period : Int
    ) : Int {
        // TODO
        fail "Not implemented.";
    }
}
