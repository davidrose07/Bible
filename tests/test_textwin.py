
import curses
from bible.textwin import TextWindow

def test_text_title(monkeypatch):
    stdscr = curses.initscr()
    win = stdscr.derwin(curses.LINES, curses.COLS, 0, 0)

    textwin = TextWindow(win, curses.COLS)
    textwin.update_text_title("John 3:16")

    assert textwin._outer_win is not None

def test_update_text(monkeypatch):
    stdscr = curses.initscr()
    win = stdscr.derwin(curses.LINES, curses.COLS, 0, 0)

    textwin = TextWindow(win, curses.COLS)
    sample_text = [
        ('In the beginning...', False, False),
        ('"Let there be light."', True, False),
        ('The Word became flesh', False, True),
    ]
    textwin.update_text(sample_text)

    assert textwin._inner_win is not None
