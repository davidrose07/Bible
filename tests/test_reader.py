import pytest
from bible.reader import Reader

def test_get_books():
    reader = Reader()
    reader.set_root("NLT")
    books = reader.get_books()
    assert "Matthew" in books

def test_get_chapters():
    reader = Reader()
    reader.set_root("NLT")
    chapters = reader.get_chapters("Matthew")
    assert "5" in chapters

def test_get_verses():
    reader = Reader()
    reader.set_root("NLT")
    verses = reader.get_verses("Matthew", "5")
    assert "3" in verses
    #TODO: uncomment when done adding titles to translations
    #assert "0" in verses  # for titles

def test_chapter_text_format():
    reader = Reader()
    reader.set_root("NLT")
    result = reader.get_chapter_text("Matthew", "5", verse_start=3)
    assert isinstance(result, list)
    assert all(isinstance(t, tuple) and len(t) == 3 for t in result)