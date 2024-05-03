from qsharptest import QSharpTest

runner = QSharpTest(namespace='MITRE.QSD.Tests.L10')


def test_L10E01():
    runner.run('E01Test')

def test_L10E02():
    runner.run('E02Test')