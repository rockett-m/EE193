# Copyright 2024 The MITRE Corporation. All Rights Reserved.


class Mod2Matrix:

    def __init__(self, rows: [[bool]] = []):
        self.rows = rows
        self.height = len(self.rows)
        if self.height > 0:
            self.width = self.rows[0]
        else:
            self.width = 0

    def rref(self):
        # start with first row
        current_row = 0
        # iterate over the columns
        for col in range(self.width):
            # find a pivot for this column
            pivot_row = self._get_pivot_row_index(col, current_row)
            if pivot_row == -1:
                # no pivot for this column
                continue
            # ensure pivot is located on current row
            self._swap_rows(pivot_row, current_row)
            # reduce remaining rows
            self._reduce(current_row, col)
            # increment current row and return if we get to the end
            current_row += 1
            if current_row == self.height - 1:
                return

    def _get_pivot_row_index(self, col: int, start_row: int):
        for row in range(start_row, self.height):
            if self.rows[row][col]:
                return row
        return -1

    def _swap_rows(self, row1: int, row2: int):
        if row1 == row2:
            return
        self.rows[row1], self.rows[row2] = self.rows[row2], self.rows[row1]

    def _reduce(self, pivot_row: int, pivot_col: int):
        for row in range(pivot_row + 1, self.height):
            if self.rows[row][pivot_col]:
                for col in range(pivot_col, self.width):
                    self.rows[row][col] ^= self.rows[pivot_row][col]

    def add_row_if_linearly_independent(self, row: [bool]):
        if self.height > 0 and self.width != len(row):
            raise Exception("Row length does not match matrix width.")
        if not any(row):
            return False
        self.rows.append(row)
        self.height += 1
        if self.height == 1:
            self.width = len(row)
        else:
            self.rref()
            if not any(self.rows[-1]):
                del self.rows[-1]
                self.height -= 1
                return False
        return True

    def augment(self):
        # In a nutshell, we are inserting an additional linearly independent
        # row after the last 1 on the diagonal and augmenting the matrix.
        insertion_index = self.height
        for i in range(0, self.height):
            if not self.rows[i][i]:
                insertion_index = i
                break
        # set up new row
        new_row = [False] * self.width
        new_row[insertion_index] = True
        # augment
        for row in self.rows:
            row.append(False)
        new_row.append(True)
        # insert new row
        self.rows.insert(insertion_index, new_row)
        self.height += 1
        self.width += 1

    def solve(self):
        # back substitution
        solution = [False] * self.height
        for row in range(self.height - 1, -1, -1):
            for col in range(row + 1, self.width - 1):
                if self.rows[row][col]:
                    self.rows[row][-1] ^= solution[col]
            solution[row] = self.rows[row][-1]
        return solution
