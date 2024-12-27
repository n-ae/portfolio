public class Solution
{
    private bool _solnFound = false;
    private const int sN = 3;
    private const int N = sN * sN;
    private const char EMPTY = '.';
    private HashSet<char> _digits = new HashSet<char>
    {
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9'
    };

    private Stack<(int row, int col)> _emptyCells = new();
    private HashSet<(int row, int col)> _emptyCells2 = new();
    private PriorityQueue<((int row, int col) cell, HashSet<char> validDigits), int> _min = new();
    private Dictionary<int, HashSet<char>> _rows = new();
    private Dictionary<int, HashSet<char>> _cols = new();
    private Dictionary<int, HashSet<char>> _subBox = new();
    private char[][] _board;

    public void SolveSudoku(char[][] board)
    {
        _board = board;
        SetState();
        Iterate();
        Backtrack();
    }

    private void MissingsState()
    {
        for (var i = 0; i < N; ++i)
        {
            _rows[i] = new HashSet<char>(_digits);
            _cols[i] = new HashSet<char>(_digits);
            _subBox[i] = new HashSet<char>(_digits);
        }
    }

    private static int Reduce(int row, int col)
    {
        return (row / sN) * sN + col / sN;
    }

    private void SetState()
    {
        MissingsState();
        for (var row = 0; row < _board.Length; ++row)
        {
            for (var col = 0; col < _board[row].Length; ++col)
            {
                var d = _board[row][col];
                if (d == EMPTY)
                {
                    _emptyCells2.Add((row, col));
                }
                else
                {
                    Place(d, row, col);
                }
            }
        }
    }

    private void Backtrack()
    {
        if (_emptyCells.Count <= 0)
        {
            _solnFound = true;
            return;
        }

        var eC = _emptyCells.Pop();

        var couldBeplacedDigits = GetValidDigits(eC.row, eC.col);
        foreach (var d in couldBeplacedDigits)
        {
            Place(d, eC.row, eC.col);
            Backtrack();
            if (_solnFound) return;
            Remove(d, eC.row, eC.col);
        }

        _emptyCells.Push(eC);
    }

    private bool Place(char d, int row, int col)
    {
        _board[row][col] = d;
        return _rows[row].Remove(d)
            && _cols[col].Remove(d)
            && _subBox[Reduce(row, col)].Remove(d)
        ;
    }

    private bool Remove(char d, int row, int col)
    {
        _board[row][col] = default;
        return _rows[row].Add(d)
            && _cols[col].Add(d)
            && _subBox[Reduce(row, col)].Add(d)
        ;
    }

    private HashSet<char> GetValidDigits(int row, int col)
    {
        var result = new HashSet<char>(_subBox[Reduce(row, col)]);
        result.IntersectWith(_cols[col]);
        result.IntersectWith(_rows[row]);
        return result;
    }

    private void CalculateAndSortMoves()
    {
        _min.Clear();
        foreach (var ec in _emptyCells2)
        {
            var v = GetValidDigits(ec.row, ec.col);
            _min.Enqueue((ec, v), v.Count);
        }
    }

    private void ExhaustSingleMoves()
    {
        while (SingleMoveExists())
        {
            var mustMove = _min.Dequeue();
            var d = mustMove.validDigits.Single();
            Place(d, mustMove.cell.row, mustMove.cell.col);
            _emptyCells2.Remove(mustMove.cell);
        }
    }

    private bool SingleMoveExists()
    {
        return _min.TryPeek(out var v, out var p) && p == 1;
    }

    private void Iterate()
    {
        CalculateAndSortMoves();
        while (SingleMoveExists())
        {
            ExhaustSingleMoves();
            CalculateAndSortMoves();
        }
        ToInversedStack();
    }

    private void ToInversedStack()
    {
        var tmp = new Stack<(int row, int col)>();

        while (_min.Count > 0)
        {
            tmp.Push(_min.Dequeue().cell);
        }

        while (tmp.Count > 0)
        {
            _emptyCells.Push(tmp.Pop());
        }
    }
}
