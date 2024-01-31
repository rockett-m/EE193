# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest
from simontest import SimonTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L06')
simon_runner = SimonTest(namespace='MITRE.QSD.Tests.L06')


def test_L06E01():
    runner.run('E01Test')


def test_L06E02():
    for input_size in [3, 6, 9]:
        expected = [False] * input_size
        expected[0] = True
        simon_runner.run('E02TestHelper', input_size, 10, expected)


def test_L06C01():
    for input_size in [3, 6, 9]:
        expected = [False] * input_size
        expected[-1] = True
        simon_runner.run('C01TestHelper', input_size, 10, expected)


def test_L06C02():
    expected = [True, True, False]
    simon_runner.run('C02TestHelper', 3, 10, expected)
