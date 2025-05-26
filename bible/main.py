#!/usr/bin/env python3.10

import os
import curses
from hyphen import Hyphenator
from textwrap import wrap
from typing import List, Tuple, Any
from .reader import Reader
from .textwin import TextWindow
from .listwin import ListWindow
from .logs import get_logger

TRANSLATIONS_WIDTH = 6
BOOKS_WIDTH = 14
CHAPTERS_WIDTH = 4
VERSES_WIDTH = 4

log_dir = os.path.join(os.path.expanduser("~"), "Bible", "logs")
os.makedirs(log_dir, exist_ok=True)

logger = get_logger(__name__)
h_en = Hyphenator("en_US")

def make_enumeration(list_: List[str]) -> List[Tuple[int, str]]:
    """
    Enumerate a list and return a list of (index, item) tuples.

    :param list_: A list of strings.
    :return: List of tuples pairing index with item.
    """
    return list(enumerate(list_))

class Main:
    def __init__(self, stdscr: Any) -> None:
        """
        Initialize the main application interface.
        
        :param stdscr: The standard screen window provided by curses.wrapper().
        """
        self.stdscr = stdscr
        self.stdscr.clear()
        
        self.initialize_reader()     # Initialize the reader to set up the document structure
        self.initialize_windows()    # Create the necessary windows for the application
        self.initialize_selections() # Set initial selections for navigation

        self.update_selections()     # Update selections based on default or initial data
        self.update_text()           # Display the initial text

        self.start_input_loop()      # Start the input event loop
   
    def initialize_reader(self) -> None:
        """Initialize the reader object for reading text data."""
        self.reader = Reader()
        self.reader.set_root("NIV")  # Set the root text version, e.g., NIV Bible

    def initialize_windows(self) -> None:
        """Initialize the windows for displaying different types of data."""
        start_x = 0

        # Translations window
        self.translations_win = ListWindow(
            self.stdscr.derwin(curses.LINES, TRANSLATIONS_WIDTH, 0, start_x),
            "TR",
            make_enumeration(self.reader.get_translations()),
            TRANSLATIONS_WIDTH,
        )

        # Books window
        start_x += TRANSLATIONS_WIDTH
        self.books_win = ListWindow(
            self.stdscr.derwin(curses.LINES, BOOKS_WIDTH, 0, start_x),
            "BOOK",
            make_enumeration(self.reader.get_books()),
            BOOKS_WIDTH,
        )

        # Chapters window
        start_x += BOOKS_WIDTH
        self.chapters_win = ListWindow(
            self.stdscr.derwin(curses.LINES, CHAPTERS_WIDTH, 0, start_x),
            "CH",
            make_enumeration(self.reader.get_chapters("Matthew")),  # Example initial book
            CHAPTERS_WIDTH,
        )

        # Verses window
        start_x += CHAPTERS_WIDTH
        self.verses_win = ListWindow(
            self.stdscr.derwin(curses.LINES, VERSES_WIDTH, 0, start_x),
            "VS",
            make_enumeration(self.reader.get_verses("Matthew", 1)),  # Example initial book and chapter
            VERSES_WIDTH,
        )

        # Text window
        start_x += VERSES_WIDTH
        self.text_width = curses.COLS - start_x
        self.text_win = TextWindow(
            self.stdscr.derwin(curses.LINES, self.text_width, 0, start_x),
            self.text_width,
        )
   
    def initialize_selections(self) -> None:
        """Initialize default selections for windows."""
        self.windows_tuples = make_enumeration(
            [self.translations_win, self.books_win, self.chapters_win, self.verses_win]
        )
        self.selected_window = self.windows_tuples[1]  # Initially select the books window
        self.selected_window[1].set_active(True)

    def update_selections(self) -> None:
        """Update the selections in response to user input or initialization."""
        trans = self.translations_win.get_selection_tuple()[1]
        self.reader.set_root(trans)

        book = self.books_win.get_selection_tuple()[1]
        chapter_tuples = make_enumeration(self.reader.get_chapters(book))
        self.chapters_win.set_selection_tuples(chapter_tuples)

        chapter = self.chapters_win.get_selection_tuple()[1]
        verses_list = [v for v in self.reader.get_verses(book,chapter) if v != "0"]
        verses_tuples = make_enumeration(verses_list)
        
        self.verses_win.set_selection_tuples(verses_tuples)

    def update_text(self) -> None:
        """Update the text display based on the current selections."""
        trans_name = self.translations_win.get_selection_tuple()[1]
        book_name = self.books_win.get_selection_tuple()[1]
        chapter_name = self.chapters_win.get_selection_tuple()[1]
        verse = self.verses_win.get_selection_tuple()[1]

        text_title = f"{book_name} {chapter_name}:{verse} [{trans_name}]"

        verse_start = int(verse)  # Ensure verse is an integer
        formatted_text_tuples: List[Tuple[str, bool, bool]] = self.reader.get_chapter_text(book_name, chapter_name, verse_start)
        
        # Wrap text with tracking red letter status
        wrapped_text_tuples: List[Tuple[str, bool, bool]] = []
        for text, is_red, is_title in formatted_text_tuples:
            wrapped_lines = wrap(text, width=self.text_win._width - 3, replace_whitespace=False)
            for line in wrapped_lines:
                wrapped_text_tuples.append((line, is_red, is_title))
        self.text_win.update_text_title(text_title)
        self.text_win.update_text(wrapped_text_tuples)
    
    def deactivate_all_windows(self) -> None:
        """Deactivate all windows, removing focus."""
        for (i, win) in self.windows_tuples:
            win.set_active(False)

    def increment_window(self, i) -> None:
        """Move the focus between windows based on user navigation input."""
        self.deactivate_all_windows()
        new_windex = self.selected_window[0] + i
        if new_windex >= len(self.windows_tuples):
            new_windex = 0
        elif new_windex < 0:
            new_windex = len(self.windows_tuples) - 1
        self.selected_window = self.windows_tuples[new_windex]
        self.selected_window[1].set_active(True)

    def start_input_loop(self) -> None:
        """Start the input loop to receive keyboard commands."""
        key = None
        while key != ord("q"):
            key = self.stdscr.getch()

            if key == curses.KEY_UP or key == ord("k"):
                self.selected_window[1].increment_selection(-1)

            elif key == curses.KEY_DOWN or key == ord("j"):
                self.selected_window[1].increment_selection(1)

            elif key == curses.KEY_LEFT or key == ord("h"):
                self.increment_window(-1)

            elif key == curses.KEY_RIGHT or key == ord("l"):
                self.increment_window(1)

            elif key == ord("g"):
                self.selected_window[1].select_first()

            self.update_selections()
            self.update_text()
        
def main() -> None:
    """Entry point for the curses application."""
    curses.wrapper(Main)

if __name__ == "__main__":
    main()
