# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L05')


def test_L05E01():
    runner.run('E01Test')


def test_L05E02():
    runner.run('E02Test')


def test_L05E03():
    runner.run('E03Test')


def test_L05E04():
    runner.run('E04Test')


def test_L05E05():
    runner.run('E05Test')
