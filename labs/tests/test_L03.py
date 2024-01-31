# Copyright 2024 The MITRE Corporation. All Rights Reserved.

from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L03')


def test_L03E01():
    runner.run('E01Test')


def test_L03E02():
    runner.run('E02Test')


def test_L03E03():
    runner.run('E03Test')


def test_L03E04():
    runner.run('E04Test')


def test_L03E05():
    runner.run('E05Test')


def test_L03E06():
    runner.run('E06Test')


def test_L03E07():
    runner.run('E07Test')


def test_L03E08():
    runner.run('E08Test')


def test_L03C01():
    runner.run('C01Test')


def test_L03C02():
    runner.run('C02Test')


def test_L03C03():
    runner.run('C03Test')


def test_L03C04():
    runner.run('C04Test')
