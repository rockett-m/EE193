# Quantum Software Development

Copyright 2024 The MITRE Corporation. All Rights Reserved.

---

This repository contains coding exercises for MITRE's Quantum Software Development course. Each lab is a Q# file with unimplemented operations. Practice your quantum software development skills by implementing each operation so it passes the unit tests.

## Setup

Since migrating to the [Modern QDK](https://learn.microsoft.com/en-us/azure/quantum/install-overview-qdk), the setup is very straightforward:

1. Install the latest version of [Python](https://www.python.org/downloads/).

2. Install [Visual Studio Code](https://code.visualstudio.com/Download).

3. Install extensions for the [QDK](https://marketplace.visualstudio.com/items?itemName=quantum.qsharp-lang-vscode) and [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python).

4. From the command line, install Python dependencies with `pip install qsharp pytest`

> It is a good idea to use a [virtual environment](https://docs.python.org/3/library/venv.html) to isolate dependencies and ensure you are targeting the right Python version.

## Getting Started

Open the repository folder in Code. The exercises are contained in the `src` directory. You can test your environment is working by opening [src/QSharpReference.qs](src/QSharpReference.qs) and clicking on the play button in the top right of the screen. This should output a message to the debug console.

Next, open [src/L01/L01.qs](src/L01/L01.qs) and try implementing the first operation. You can test for correctness by clicking on the "Testing" tab in the ribbon on the left side of the screen and running the test for Lab 1, Exercise 1. (You may need to open a unit test file in the `tests` directory for it to appear.) Alternatively, run all the tests from the command line with `pytest`.

> You can run just the tests for a particular lab by specifying the unit test file, e.g., `pytest tests/test_L01.py`.

## Assignment Submission

For full credit, upload the following to Canvas:

- The Q# file with your code implementing the operations.

- A screenshot showing evidence of the unit tests passing.
