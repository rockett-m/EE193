// Quantum Software Development
// Lab 9: Shor's Factorization Algorithm
// Copyright 2024 The MITRE Corporation. All Rights Reserved.
//
// Due 4/26.
//
// run on single test without messages output:
// pytest -s tests/test_L09.py::test_L09E04
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

        let n = Ceiling(Lg(IntAsDouble(modulus + 1)));
        Message($"Number to factor: {modulus}, Guess: {base}");
        // Message($"Number of qubits: {n*2} (input), {n} (output)");

        // create input and output registers with 2n and n qubits respectively
        use (inputReg, outputReg) = (Qubit[n*2], Qubit[n]);
        // Message($"Input register size: {numInputQubits}, Output register size: {numOutputQubits}");
        // apply Hadamard gate to the input register for uniform superposition
        mutable measured = 0;
        within {
            ApplyToEachA(H, inputReg);
        } apply {
            // apply the quantum modular exponentiation function
            E01_ModExp(base, modulus, inputReg, outputReg);
            // apply the inverse quantum Fourier transform
            Adjoint E01_QFT(inputReg);
            // measure the input register
            set measured = MeasureInteger(inputReg);
            // reset qubits
            // return the measured value and the denominator (solution space size)
        }
        ResetAll(inputReg); ResetAll(outputReg);
        // return the measured value and the denominator (solution space size)
        // Message($"Measured: {measured}, 2^(2*n): {2^(2*n)}");
        return (measured, 2^(2^n));
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
        mutable highestConvergent = (0, 1);

        // avoid division by zero
        mutable p = [0, 1];
        mutable q = [1, 0];
        // m_i = a_i * m_{i-1} + m_{i-2}
        // d_i = a_i * d_{i-1} + d_{i-2}

        mutable finish = false;

        // denominatorThreshold is the maximum value for the denominator
        for i in 2 .. denominatorThreshold {
            if not finish {

                let a_i = Floor(IntAsDouble(numer_test) / IntAsDouble(denom_test));
                let remainder = numer_test - (a_i * denom_test);

                // append new fraction to end of list
                set p += [p[0] + p[1] * a_i];
                set q += [q[0] + q[1] * a_i];

                // pop first element to keep list size of 3 [i-2, i-1, curr]
                set p = p[1 .. Length(p)-1];
                set q = q[1 .. Length(q)-1];

                if (q[Length(q)-1] <= denominatorThreshold) {
                    set convergent = (p[Length(p)-1], q[Length(q)-1]);
                }

                if (remainder == 0) {
                    set finish = true;
                } else {
                    set numer_test = denom_test;
                    set denom_test = remainder;
                }

                let (highestNum, highestDen) = highestConvergent;
                let (num, den) = convergent;
                if ((num / den >= highestNum / highestDen) and (den > highestDen)) {
                    set highestConvergent = convergent;
                }

            }
        }
        // print convergent for debugging
        let (highestNumerator, highestDenominator) = highestConvergent;
        if highestNumerator > 0 and highestDenominator > 0 {
            Message($"Highest convergent: {highestConvergent}");
        } else {
            // Message($"Convergent: {convergent}");
        }
        return highestConvergent;
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
    operation E04_FindPeriod (
        numberToFactor : Int,
        initialGuess : Int
    ) : Int {
        // Hint: you can use the Microsoft.Quantum.Math.ExpModI() function to
        // calculate a modular exponent classically.

        // TODO
        Message("");
        Message($"Number to factor: {numberToFactor}, Initial guess: {initialGuess}");
        Message("");
        // we know that guess is not a factor of numberToFactor
        // 1 < guess < numberToFactor
        // Check if the period candidate is valid
        mutable guess = initialGuess;
        mutable periodFound = false;
        mutable period = guess;

        // if calling ExpMod, which is the costliest operation, use Quantum Exp not classical
        let n = Ceiling(Lg(IntAsDouble(numberToFactor + 1)));

        repeat {
            // Message($"Trying with guess: {guess}");

            let gcd = GreatestCommonDivisorI(guess, numberToFactor);
            if (gcd == 1) {
                // Message($"Trying with guess: {guess}");
                let n = Ceiling(Lg(IntAsDouble(numberToFactor + 1)));
                let (numInputQubits, numOutputQubits) = (n*2, n);

                let (measured, _) = E02_FindApproxPeriod(numberToFactor, guess);
                let (_, candidatePeriod) = E03_FindPeriodCandidate(measured, 2^numInputQubits, numberToFactor);
                // Message($"Measured: {measured}, Size: {size}, Candidate period: {candidatePeriod}");

                // Verify the candidate period with a classical check (even and > 1)
                if (candidatePeriod % 2 == 0 and candidatePeriod > 0) {
                    // Check if the period candidate is valid
                    mutable modExpG = 0;
                    Message($"Checking period candidate: {candidatePeriod}; Guess: {guess}");

                    // Quantum circuit to check the period candidate
                    // use (inputQubits, outputQubits) = (Qubit[n*2], Qubit[n]);
                    // within {
                    //     ApplyToEachA(H, inputQubits);
                    // } apply {
                    //     Message($"guess: {guess}, candidatePeriod: {candidatePeriod}");
                    //     E01_ModExp(guess, candidatePeriod / 2, inputQubits, outputQubits);
                    //     Message($"ModExp done");
                    //     Adjoint E01_QFT(inputQubits);

                    //     set modExpG = MeasureInteger(inputQubits);
                    //     Message($"Measured: {modExpG}");
                    // }
                    // ResetAll(inputQubits); ResetAll(outputQubits);
                    // End of quantum circuit

                    // Classical check
                    let modExpG = ExpModI(guess, candidatePeriod / 2, numberToFactor);

                    let lower = GreatestCommonDivisorI(modExpG - 1, numberToFactor);
                    let upper = GreatestCommonDivisorI(modExpG + 1, numberToFactor);
                    Message($"Lower: {lower}, Upper: {upper}");

                    if (numberToFactor % lower == 0 and lower < numberToFactor) {
                        Message($"[FOUND] Lower factor: {lower}; Period: {candidatePeriod}");
                        set period = candidatePeriod;
                        set periodFound = true;
                        return period;
                    }
                    elif (numberToFactor % upper == 0 and upper < numberToFactor) {
                        Message($"[FOUND] Upper factor: {upper}; Period: {candidatePeriod}");
                        set period = candidatePeriod;
                        set periodFound = true;
                        return period;
                    }
                    else {
                        Message($"[x] [invalid] Period candidate {candidatePeriod} failed the factor check");
                    }
                    Message($"[x] [mod] Period candidate {candidatePeriod} failed the mod check");
                }
            }

            set guess = (guess + 1) % numberToFactor;
            if guess < 1 { set guess = 1; }

        } until periodFound;

        return period;
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
        // if the period is odd, return -1
        if (period % 2 == 1) {
            return -1;
        }
        // check lower and upper gcds
        let gcd_low = GreatestCommonDivisorI(ExpModI(guess, period / 2, numberToFactor) - 1, numberToFactor);
        if (gcd_low != 1 and gcd_low != numberToFactor) {
            return gcd_low;
        }
        let gcd_high = GreatestCommonDivisorI(ExpModI(guess, period / 2, numberToFactor) + 1, numberToFactor);
        if (gcd_high != 1 and gcd_high != numberToFactor) {
            return gcd_high;
        }
        // can't factor, defaults to -2
        return -2;
    }
}
