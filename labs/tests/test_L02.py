# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L02')


def test_L02E01():
    runner.run('E01Test')


def test_L02E02():
    runner.run('E02Test')


def test_L02E03():
    runner.run('E03Test')


def test_L02E04():
    runner.run('E04Test')
