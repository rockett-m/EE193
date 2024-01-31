# Copyright 2024 The MITRE Corporation. All Rights Reserved.

import qsharp


class QSharpTest:

    def __init__(self, project_root: str = './', namespace: str = ''):
        qsharp.init(project_root=project_root)
        self.project_root = project_root
        self.namespace = namespace

    def run(self, test_name: str):
        entry_expr = '.'.join([self.namespace, test_name]) + '()'
        result = qsharp.run(entry_expr=entry_expr, shots=1)[0]
        if isinstance(result, qsharp.QSharpError):
            raise result
        return result
