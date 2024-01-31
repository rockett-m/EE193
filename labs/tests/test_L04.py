# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L04')


def test_L04E01():
    runner.run('E01Test')


def test_L04E02():
    runner.run('E02Test')


def test_L04E03():
    runner.run('E03Test')


def test_L04E04():
    runner.run('E04Test')


def test_L04E05():
    runner.run('E05Test')


def test_L04E06():
    runner.run('E06Test')


def test_L04E07():
    runner.run('E07Test')


def test_L04C01():
    runner.run('C01Test')


def test_L04C02():
    runner.run('C02Test')


def test_L04C03():
    runner.run('C03Test')


def test_L04C04():
    runner.run('C04Test')


def test_L04C05():
    runner.run('C05Test')
