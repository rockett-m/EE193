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
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Unstable.Arithmetic;


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
        // apply X gate to the last qubit of the output register (LSB)
        X(output[Length(output) - 1]);
        let n = Length(input);

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

        let inputQubits = 2*Ceiling(Lg(IntAsDouble(modulus + 1)));
        Message(""); Message($"Number to factor: {modulus}, Guess: {base}");

        // create input and output registers with 2n and n qubits respectively
        use (inputReg, outputReg) = (Qubit[inputQubits], Qubit[inputQubits/2]);
        // Message($"Input register size: {inputQubits}, Output register size: {inputQubits/2}");

        // apply Hadamard gate to the input register for uniform superposition
        ApplyToEach(H, inputReg);

        // apply the quantum modular exponentiation function
        E01_ModExp(base, modulus, inputReg, outputReg);
        // apply the inverse quantum Fourier transform
        Adjoint ApplyQFT(inputReg);
        // measure the input register
        let measured = MeasureInteger(inputReg);

        ResetAll(inputReg); ResetAll(outputReg);
        // Message($"Measured: {measured}, solutionSpace: {2^(inputQubits)}");
        return (measured, 2^inputQubits);
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
        // Message("");
        Message($"Input:
            Numerator: {numerator},
            Denominator: {denominator},
            Denominator Threshold: {denominatorThreshold}");
        // can't divide by zero
        if (denominator == 0 or denominatorThreshold == 0) {
            Message("[Error] Denominator or denominator threshold is zero");
            return (0, 0);
        } elif (numerator == 0) { // no need to expand
            // Message("Numerator is zero");
            return (0, 1);
        }

        // initialize variables (current numerator and denominator)
        mutable (P_i, Q_i) = (numerator, denominator); // init as input
        mutable (a_i, r_i, v_i) = (0, 0, 0.0); // set these in the calcs

        // initial convergents
        mutable (m_arr, d_arr) = ([0, 1], [1, 0]);
        // on iteration 0, m_i and d_i get calculated
        mutable (m_i, d_i) = (0, 0);

        // loop until we find a convergent with a denominator less than the threshold
        mutable (i, done, iterations) = (0, false, 0);

        // loop until we find a convergent with a denominator less than the threshold
        while d_i < denominatorThreshold and not done and iterations < 20 {
            // print out all variables and the variable name in front of them
            // Message("---------------------------");
            // Message($"Beginning of iteration {iterations}"); Message("");

            // int division quotient, remainder
            set a_i = Floor(IntAsDouble(P_i) / IntAsDouble(Q_i));
            set r_i = P_i % Q_i;

            // calculate convergent
            set m_i = a_i * m_arr[Length(m_arr)-1] + m_arr[Length(m_arr)-2];
            set d_i = a_i * d_arr[Length(d_arr)-1] + d_arr[Length(d_arr)-2];

            set v_i = IntAsDouble(m_i) / IntAsDouble(d_i);
            // Message("Updated after calculatons");
            // Message($"a_i: {a_i}; r_i: {r_i}; v_i: {v_i}"); Message("");

            set m_arr += [m_i];
            set d_arr += [d_i];
            // drop first element and append new element
            if Length(m_arr) > 3 {
                set m_arr = m_arr[1 .. Length(m_arr)-1];
                set d_arr = d_arr[1 .. Length(d_arr)-1];
            }

            set (P_i, Q_i) = (Q_i, r_i);

            // if remainder is zero, we are done
            if r_i == 0 {
                // Message("Remainder is zero, we are done");
                set done = true;
            }
            set iterations += 1;
        }

        // Decide which to return
        if Q_i == 0 and d_arr[2] < denominatorThreshold and d_arr[2] > 0 {
            // Message($"[Peak Convergent (curr)]: {m_arr[2]}, {d_arr[2]} [RETURN]");
            return (m_arr[Length(m_arr)-1], d_arr[Length(d_arr)-1]);
        } else {
            // Message($"[Peak Convergent (prev)]: {m_arr[1]}, {d_arr[1]} [RETURN]");
            return (m_arr[Length(m_arr)-2], d_arr[Length(d_arr)-2]);
        }
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
    // Hint: you can use the Microsoft.Quantum.Math.ExpModI() function to
    // calculate a modular exponent classically.
    operation E04_FindPeriod (
        numberToFactor : Int,
        initialGuess : Int
    ) : Int {
        // TODO
        Message("---------------------------");
        Message($"Number to factor: {numberToFactor}, Initial guess: {initialGuess}"); Message("");
        // we know that guess is not a factor of numberToFactor // 1 < guess < numberToFactor
        mutable (guess, period, periodFound, numGuesses) = (initialGuess, 1, false, 100);
        // Find the period guess^x mod numberToFactor
        repeat {
            if GreatestCommonDivisorI(guess, numberToFactor) == 1 { // coprime
                // Measure some X such that X/2^n is close to the period m/p
                mutable (measured, size) = (0, 0);
                repeat { set (measured, size) = E02_FindApproxPeriod(numberToFactor, guess);
                } until measured != 0; // need non-zero measurement

                // Do continued fraction expansion on X / 2^n
                mutable (_, candidatePeriod) = E03_FindPeriodCandidate(measured, size, numberToFactor);

                // Set the period to the LCM of the candidate period and the current period
                let gcd_periods = GreatestCommonDivisorI(candidatePeriod, period);
                set period = period * candidatePeriod / gcd_periods;
                // Message($"gcd_periods: {gcd_periods}; Updated period: {period}"); Message("");

                // Check if guess^period mod numberToFactor is 1 (coprime)
                if ExpModI(guess, period, numberToFactor) == 1 {
                    Message($"Period found: {period}"); Message("");
                    set periodFound = true; // done
                }
            }
            set numGuesses -= 1;
        }
        until periodFound or numGuesses <= 0;

        if (numGuesses <= 0) { Message("[Error] Number of guesses exceeded"); }

        Message($"Returning period as: {period}");
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
        let expMod = ExpModI(guess, period / 2, numberToFactor);
        let gcd_low = GreatestCommonDivisorI(expMod - 1, numberToFactor);
        let gcd_high = GreatestCommonDivisorI(expMod + 1, numberToFactor);
        // check lower and upper gcds
        if (gcd_low != 1 and gcd_low != numberToFactor) {
            return gcd_low;
        } elif (gcd_high != 1 and gcd_high != numberToFactor) {
            return gcd_high;
        } else { // period doesn't work for factoring
            return -2;
        }
    }
}
