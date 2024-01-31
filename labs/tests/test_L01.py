# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L01')


def test_L01E01():
    runner.run('E01Test')


def test_L01E02():
    runner.run('E02Test')
