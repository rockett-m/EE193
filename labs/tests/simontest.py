# Copyright 2024 The MITRE Corporation. All Rights Reserved.

import qsharp
from qsharptest import QSharpTest
from matrixmath import Mod2Matrix


class SimonTest(QSharpTest):

    def run(self, test_name: str, input_size: int, extra_rounds: int,
            expected: [bool]):
        print(f"Running Simon's algorithm on {test_name} with {input_size}" +
              " qubits.")
        entry_expr = '.'.join([self.namespace, test_name]) + f'({input_size})'
        matrix = Mod2Matrix(rows=[])
        for _ in range(input_size + extra_rounds - 1):
            result = qsharp.run(entry_expr=entry_expr, shots=1)[0]
            if isinstance(result, qsharp.QSharpError):
                raise result
            print(f'Got result from Simon subroutine: {result}')
            if matrix.add_row_if_linearly_independent(result):
                print('Linearly independent; added.')
            else:
                print('Not linearly independent; ignored.')
            if matrix.height == input_size - 1:
                break
        if matrix.height < input_size - 1:
            raise Exception('Did not get enough linearly independent results')
        matrix.augment()
        solution = matrix.solve()
        print(f'Got solution: {solution}')
        assert solution == expected
