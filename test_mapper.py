# test_mapper.py
from mapper import process_line

def test_process_line():
    assert process_line("apple\t1") == ("apple", 1)
