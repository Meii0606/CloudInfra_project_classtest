# test_reducer.py
from reducer import reduce_lines

def test_reduce_single_word():
    lines = ["apple\t1\n", "apple\t2\n"]
    result = reduce_lines(lines)
    assert result == ["Modified: apple\t3"]
