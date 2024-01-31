# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L08')


def test_L08E01():
    runner.run('E01Test')


def test_L08E02():
    runner.run('E02Test')
