
import curses
from bible.listwin import ListWindow

def test_select_first(monkeypatch):
    stdscr = curses.initscr()
    items = list(enumerate(["Genesis", "Exodus", "Leviticus"]))
    win = stdscr.derwin(curses.LINES, 10, 0, 0)

    listwin = ListWindow(win, "BOOKS", items, 10)
    listwin.select_first()

    assert listwin.get_selection_tuple() == (0, "Genesis")

def test_set_selection_tuples(monkeypatch):
    stdscr = curses.initscr()
    items = list(enumerate(["One", "Two", "Three"]))
    win = stdscr.derwin(curses.LINES, 10, 0, 0)

    listwin = ListWindow(win, "Test", items, 10)
    new_items = list(enumerate(["Four", "Five"]))
    listwin.set_selection_tuples(new_items)

    assert listwin.get_selection_tuple()[1] == "Four"
