# test_mapper.py
from mapper import map_line

def test_map_line_single_word():
    assert map_line("hello") == ["hello\t1"]

def test_map_line_multiple_words():
    assert map_line("hello world") == ["hello\t1", "world\t1"]

def test_map_line_with_extra_spaces():
    assert map_line("  hello   world  ") == ["hello\t1", "world\t1"]
