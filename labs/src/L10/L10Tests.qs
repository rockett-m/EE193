namespace MITRE.QSD.Tests.L10 {
    open MITRE.QSD.L10;

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;


    operation E00Test() : Unit {
        // E00_Add_Two_Ints
        // use values from 0 to 1023 for a, b

        let tests = [
            (0, 0, 0, 0, 0),
            (0, 0, 1, 1, 0),
            (0, 1, 0, 1, 0),
            (0, 1, 1, 0, 1),
            (1, 0, 0, 1, 0),
            (1, 0, 1, 0, 1),
            (1, 1, 0, 0, 1),
            (1, 1, 1, 1, 1)];

        for (a, b, carryIn, expectedSum, expectedCarryOut) in tests {
            let (sum, carryOut) = E00_Add_Two_Ints(a, b, carryIn);
            Fact(
                sum == expectedSum and carryOut == expectedCarryOut,
                $"Error: Expected {expectedSum}, {expectedCarryOut}"
            );
        }

    }


    operation E01Test() : Unit {
        let (a, b, carryIn) = (1, 0, 0);
        // mutable (sum, carryOut) = (0, 0);

        let (sum, carryOut) = E01_FullAdder_1Bit(a, b, carryIn);

        Fact(
            sum == 1 and carryOut == 0,
            "Error: Expected 1"
        );

        // Test all possible inputs
        // a, b, carryIn, expectedSum, expectedCarryOut
        let tests = [
            (0, 0, 0, 0, 0),
            (0, 0, 1, 1, 0),
            (0, 1, 0, 1, 0),
            (0, 1, 1, 0, 1),
            (1, 0, 0, 1, 0),
            (1, 0, 1, 0, 1),
            (1, 1, 0, 0, 1),
            (1, 1, 1, 1, 1)];

        for (a, b, carryIn, expectedSum, expectedCarryOut) in tests {
            let (sum, carryOut) = E01_FullAdder_1Bit(a, b, carryIn);
            Fact(
                sum == expectedSum and carryOut == expectedCarryOut,
                $"Error: Expected {expectedSum}, {expectedCarryOut}"
            );
        }
    }


    operation E02Test() : Unit {
        // return (0, 0) from input handling when invalid inputs are provided
        let tests_full_adder_invalid_inputs = [
            (-1, 0, 0, 0, 0),  // Negative a
            (0, -1, 0, 0, 0),  // Negative b
            (0, 0, -1, 0, 0),  // Negative carryIn
            (-1, -1, 0, 0, 0),  // Negative a and b
            (1025, 0, 0, 0, 0),  // a above 2^10
            (0, 1025, 0, 0, 0),  // b above 2^10
            (1025, 1025, 0, 0, 0),  // a and b above 2^10
            (0, 0, 2, 0, 0),  // carryIn > 1
            (1025, 0, 2, 0, 0),  // a above 2^10 and invalid carryIn
            (0, 1025, 2, 0, 0),  // b above 2^10 and invalid carryIn
            (1025, 1025, 2, 0, 0),  // a and b above 2^10 and invalid carryIn
            (-1, 0, 2, 0, 0),  // Negative a and invalid carryIn
            (0, -1, 2, 0, 0),  // Negative b and invalid carryIn
            (-1, -1, 2, 0, 0)  // Negative a, b, and invalid carryIn
        ];

        for (a, b, carryIn, expectedSum, expectedCarryOut) in tests_full_adder_invalid_inputs {
            let (sum, carryOut, valid) = E02_InputHandling(a, b, carryIn);
            Fact(
                valid == false,
                $"Error: Expected false but got {valid}; with a: {a}, b: {b}, carryIn: {carryIn}"
            );
        }
    }


    operation E03Test() : Unit {

        let tests = [
            (0, 0, 0, 0),
            (511, 512, 1023, 0),
            (333, 690, 1023, 0),
            (500, 523, 1023, 0),
            (500, 500, 1000, 0),
            (101, 922, 1023, 0),
            (10, 1003, 1013, 0),
            (999, 24, 1023, 0),
            (333, 690, 1023, 0),
            (500, 500, 1000, 0),
            (204, 819, 1023, 0),
            (1023, 0, 1023, 0),
            (0, 1023, 1023, 0),
            (512, 511, 1023, 0),
            (700, 323, 1023, 0),
            (450, 573, 1023, 0),
            (1010, 1010, 2020, 0), // fails when sum is > 1023
            (1023, 1024, 0, 0), // max can be 1023*2 (+ 1 if carry on)
            (1023, 1023, 2046, 0),
            (1024, 1, 0, 0), // double 0,0 if invalid input
            (100, -5, 0, 0), // invalid test
            (1024, 1024, 0, 0), // invalid test
            (1023, 1, 1024, 0),
            (1023, 1023, 2046, 0),
            (-1, 100, 0, 0) // invalid test
        ];

        for test in tests {
            let (a, b, expectedSum, expectedCarry) = test;
            let (sum, carryOut) = E03_FullAdder_nBits(a, b);
            Message($"Testing addition of {a} and {b}: ");
            Message($"Expected (Carry, Sum) = ({expectedCarry}, {expectedSum}) | Obtained = ({carryOut}, {sum})");
            Fact(
                sum == expectedSum and carryOut == expectedCarry,
                $"Test failed for inputs {a} and {b}. Expected sum {expectedSum} and carry {expectedCarry}, but got sum {sum} and carry {carryOut}."
            );
            Message("PASSED $$$$$$$$$$$$$$$$$$$$$$$$$$$$"); Message("");
        }
        Message(""); Message(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        Message("E03Test: Full Adder Multi Bit Test Passed");
        Message(""); Message(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }


    operation E04Test() : Unit {

        let tests_full_adder_nBits = [
            (1023, 0, 0, 1023, 0),
            (1023, 0, 1, 1024, 0),
            (1023, 1, 0, 1024, 0),
            (1023, 1, 1, 1025, 0),
            (0, 1023, 0, 1023, 0),
            (0, 1023, 1, 1024, 0),
            (1, 1023, 0, 1024, 0),
            (1, 1023, 1, 1025, 0),
            (1023, 1023, 0, 2046, 0),
            (1023, 1023, 1, 2047, 0),
            (512, 511, 0, 1023, 0),
            (512, 511, 1, 1024, 0),
            (256, 767, 0, 1023, 0),
            (256, 767, 1, 1024, 0),
            (767, 256, 0, 1023, 0),
            (767, 256, 1, 1024, 0),
            (500, 523, 0, 1023, 0),
            (500, 523, 1, 1024, 0),
            (523, 500, 0, 1023, 0),
            (523, 500, 1, 1024, 0),
            (1023, 1, 0, 1024, 0),
            (1023, 1, 1, 1025, 0)
        ];

        mutable counter = 0;
        for test_input in tests_full_adder_nBits {
            let (a, b, carryIn, expectedSum, expectedCarryOut) = test_input;
            let (sum, carryOut) = E04_temp(a, b, carryIn);
            Fact(
                sum == expectedSum and carryOut == expectedCarryOut,
                $"Error: Expected {expectedSum}, {expectedCarryOut}"
            );
            Message(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        }
        Message(""); Message(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        Message("E04Test: Full Adders N Bits Test Passed");
        Message(""); Message(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }

}
