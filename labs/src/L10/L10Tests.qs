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


    operation E03Test() : Unit {

        let tests = [
            // existing test cases...
            // sum between 1024 and 1100
            (512, 513, 1025, 0),
            (550, 550, 1100, 0),
            (1023, 77, 1100, 0),

            // sum between 1100 and 1200
            (600, 500, 1100, 0),
            (1023, 177, 1200, 0),
            (600, 600, 1200, 0),

            // sum between 1200 and 1300
            (650, 550, 1200, 0),
            (1023, 277, 1300, 0),
            (650, 650, 1300, 0),

            // sum between 1300 and 1400
            (700, 600, 1300, 0),
            (1023, 377, 1400, 0),
            (700, 700, 1400, 0),

            // sum between 1400 and 1500
            (750, 650, 1400, 0),
            (1023, 477, 1500, 0),
            (750, 750, 1500, 0),

            // sum between 1500 and 1600
            (800, 700, 1500, 0),
            (1023, 577, 1600, 0),
            (800, 800, 1600, 0),

            // sum between 1600 and 1700
            (850, 750, 1600, 0),
            (1023, 677, 1700, 0),
            (850, 850, 1700, 0),

            // sum between 1700 and 1800
            (900, 800, 1700, 0),
            (1023, 777, 1800, 0),
            (900, 900, 1800, 0),

            // sum between 1800 and 1900
            (950, 850, 1800, 0),
            (1023, 877, 1900, 0),
            (950, 950, 1900, 0),

            // sum between 1900 and 2000
            (1000, 900, 1900, 0),
            (1023, 977, 2000, 0),
            (1000, 1000, 2000, 0),

            // sum between 2000 and 2100
            (1050, 950, 2000, -1),
            (1023, 1077, 2100, -1),
            (1050, 1050, 2100, -1),

            // sum between 2100 and 2200
            (1100, 1000, 2100, -1),
            (1023, 1177, 2200, -1),
            (1100, 1100, 2200, -1),

            // sum between 2200 and 2300
            (1150, 1050, 2200, -1),
            (1023, 1277, 2300, -1),
            (1150, 1150, 2300, -1),

            // sum between 2300 and 2400
            (1200, 1100, 2300, -1),
            (1023, 1377, 2400, -1),
            (1200, 1200, 2400, -1),

            // sum between 2400 and 2500
            (1250, 1150, 2400, -1),
            (1023, 1477, 2500, -1),
            (1250, 1250, 2500, -1),

            // sum between 2500 and 2600
            (1300, 1200, 2500, -1),
            (1023, 1577, 2600, -1),
            (1300, 1300, 2600, -1),
        ];

        for test in tests {
            let (a, b, expectedSum, valid) = test;
            let sum = E03_RippleCarryAdderTwoInts(a, b);
            Message($"Testing addition of {a} and {b}: ");
            Fact(
                (valid == 0 and sum == expectedSum) or (valid == -1 and sum != expectedSum),
                $"Test failed for inputs {a} and {b}. Expected sum {expectedSum} and valid {valid}, but got sum {sum} and valid {valid}"
            );
            Message("PASSED $$$$$$$$$$$$$$$$$$$$$$$$$$$$"); Message("");
        }
        Message(""); Message(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
        Message("E03Test: Full Adder Multi Bit Test Passed");
        Message(""); Message(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }
}
