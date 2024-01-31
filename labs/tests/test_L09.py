# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L09')


def test_L09E01():
    runner.run('E01Test')


def test_L09E02():
    runner.run('E02Test')


def test_L09E03():
    runner.run('E03Test')


def test_L09E04():
    runner.run('E04Test')


def test_L09E05():
    runner.run('E05Test')
