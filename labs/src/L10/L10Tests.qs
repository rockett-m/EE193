namespace MITRE.QSD.Tests.L10 {
    open MITRE.QSD.L10;

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;


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

        let tests_one_full_adder = [
            (0, 0, 0, 0, 0),
            (0, 0, 1, 1, 0),
            (0, 1, 0, 1, 0),
            (0, 1, 1, 0, 1),
            (1, 0, 0, 1, 0),
            (1, 0, 1, 0, 1),
            (1, 1, 0, 0, 1),
            (1, 1, 1, 1, 1)];

        let tests_chained_full_adders = [
            (1, 1, 1, 3, 0),
            (1, 2, 0, 3, 0),
            (1, 2, 1, 4, 0),
            (1, 4, 0, 5, 0),
            (1, 4, 1, 6, 0),
            (1, 8, 0, 9, 0),
            (1, 8, 1, 10, 0),
            (1, 16, 0, 17, 0),
            (1, 16, 1, 18, 0),
            (1, 32, 0, 33, 0),
            (1, 32, 1, 34, 0),
            (1, 64, 0, 65, 0),
            (1, 64, 1, 66, 0),
            (1, 128, 0, 129, 0),
            (1, 128, 1, 130, 0),
            (1, 256, 0, 257, 0),
            (1, 256, 1, 258, 0),
            (1, 512, 0, 513, 0),
            (1, 512, 1, 514, 0),
            (1, 1024, 0, 1025, 0),
            (1, 1024, 1, 1026, 0),
            (2, 2, 0, 4, 0),
            (2, 2, 1, 5, 0),
            (2, 4, 0, 6, 0),
            (2, 4, 1, 7, 0),
            (2, 8, 0, 10, 0),
            (2, 8, 1, 11, 0),
            (2, 16, 0, 18, 0),
            (2, 16, 1, 19, 0),
            (2, 32, 0, 34, 0),
            (2, 32, 1, 35, 0),
            (2, 64, 0, 66, 0),
            (2, 64, 1, 67, 0),
            (2, 128, 0, 130, 0),
            (2, 128, 1, 131, 0),
            (2, 256, 0, 258, 0),
            (2, 256, 1, 259, 0),
            (2, 512, 0, 514, 0),
            (2, 512, 1, 515, 0),
            (2, 1024, 0, 1026, 0),
            (2, 1024, 1, 1027, 0),
            (1001, 1001, 0, 2002, 0),
            (1001, 1001, 1, 2003, 0),
            (1001, 2002, 0, 3003, 0),
            (1001, 2002, 1, 3004, 0),
            (2002, 1001, 0, 3003, 0),
            (2002, 1001, 1, 3004, 0),
            (2002, 2002, 0, 4004, 1),
            (2002, 2002, 1, 4005, 1),
            (1024, 1024, 0, 2048, 0),
            (1024, 1024, 1, 2049, 0)
        ];

        for test_bench in [tests_one_full_adder, tests_chained_full_adders] {
            for (a, b, carryIn, expectedSum, expectedCarryOut) in test_bench {
                let (sum, carryOut) = E02_FullAdder_nBits(a, b, carryIn);
                Fact(
                    sum == expectedSum and carryOut == expectedCarryOut,
                    $"Error: Expected {expectedSum}, {expectedCarryOut}"
                );
            }
        }

    }
}