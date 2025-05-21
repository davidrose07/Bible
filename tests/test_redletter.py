import pytest
from bible.redletter import RedLetter

def test_is_red_letter_true():
    rl = RedLetter()
    assert rl.is_red_letter("Matthew", "5", "3") is True
    assert rl.is_red_letter("John", "3", "16") is True

def test_is_red_letter_false():
    rl = RedLetter()
    assert rl.is_red_letter("Matthew", "5", "1") is False
    assert rl.is_red_letter("Luke", "1", "1") is False

def test_invalid_inputs():
    rl = RedLetter()
    assert rl.is_red_letter("Unknown", "1", "1") is False
    assert rl.is_red_letter("Matthew", "abc", "1") is False
    assert rl.is_red_letter("Matthew", "1", "xyz") is False