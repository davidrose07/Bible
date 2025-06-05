from glob import glob
from os.path import splitext, basename, dirname, join
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import ElementTree, Element
from typing import List, Tuple, Dict
from .redletter import RedLetter
from .logs import get_logger

TRANSLATIONS_DIR = join(dirname(__file__), "translations")  # Path to the translations directory

logger = get_logger(__name__)

class Reader:
    def __init__(self) -> None:
        """Initialize the Reader object and load available Bible translations into memory."""
        logger.info("Initialzing Reader Object. . .")
        self.red_letter = RedLetter()
        self._load_roots()
         
    
    def _load_roots(self) -> None:
        """Load root elements for all available translations from XML files."""
        logger.info("Loading roots. . .")
        self._current_root = (None, None)  # Initialize the current root as None
        self._roots: Dict = {}                   # Dictionary to store root elements by translation
        for ts in self.get_translations():
            self._roots[ts] = self._get_root(ts)

    def _get_root(self, translation_str: str) -> ElementTree:
        """Parse the XML file for a given translation and return the root element.
            Args:
                translation_str: The name of the translation (e.g., 'kjv').

            Returns:
                The parsed ElementTree for the translation.
        """
        return ET.parse("{0}/{1}.xml".format(TRANSLATIONS_DIR, translation_str))

    def set_root(self, translation_str: str) -> None:
        """Set the current root to a specific translation if not already set.
            Args:
                translation_str: The translation to set as the current root.
        """
        if self._current_root[0] == translation_str:
            return
        self._current_root = (translation_str, self._roots[translation_str])
        logger.info(f"Current root set to: {self._current_root}")

    def get_translations(self) -> List[str]:
        """Retrieve a list of available translation names by reading XML files in the translations directory.
            Returns:
                A list of translation names (without the '.xml' extension).
        """
        return [
            splitext(basename(f))[0] for f in glob("{0}/*.xml".format(TRANSLATIONS_DIR))
        ]

    def get_books(self) -> List[str]:
        """Return a list of books available in the current translation.
            Returns:
                A list of book names as strings.
        """
        return [bel.attrib["n"] for bel in self._current_root[1].findall("b")]

    def get_chapters(self, book_str: str) -> List[str]:
        """Return a list of chapter numbers for a given book in the current translation.
            Args:
                book_str: The book name.

            Returns:
                A list of chapter numbers as strings.
        """
        return [
            chel.attrib["n"]
            for chel in self._current_root[1]
            .find("b[@n='{0}']".format(book_str))
            .findall("c")
        ]
    
    def get_verses_elements(self, book_str: str, chapter_str: str) -> List[Element]:
        """Retrieve XML elements for all verses in a given book and chapter.
            Args:
                book_str: The book name.
                chapter_str: The chapter number.

            Returns:
                A list of verse XML elements.
        """
        return (
            self._current_root[1]
            .find("b[@n='{0}']".format(book_str))
            .find("c[@n='{0}']".format(chapter_str))
            .findall("v")
        )

    def get_verses(self, book_str: str, chapter_str: str) -> List[str]:
        """Return a list of verse numbers for a specific book and chapter.
            Args:
                book_str: The book name.
                chapter_str: The chapter number.

            Returns:
                A list of verse numbers as strings.
        """
        return [
            vel.attrib["n"] for vel in self.get_verses_elements(book_str, chapter_str)
        ]

    def get_chapter_text(self, book_str: str, chapter_str: str, verse_start: int = 1) -> List[Tuple[str, bool, bool]]:
        """Return a list of tuples for each verse or title in a chapter.

        Each tuple contains:
            - The text of the verse or title.
            - A boolean indicating if it is a red-letter verse.
            - A boolean indicating if it is a title.

        Args:
            book_str: The book name.
            chapter_str: The chapter number.
            verse_start: The starting verse number (default is 1).

        Returns:
            A list of (text, is_red, is_title) tuples for the chapter."""
        verses_elements = self.get_verses_elements(book_str, chapter_str)
        text_with_red = []

        current_title = None
        found_verse_start = False

        for v in verses_elements:
            verse_n = v.attrib["n"]

            if verse_n == "0":
                current_title = v.text.strip()
                # If we've already passed verse_start, show titles normally
                if found_verse_start:
                    text_with_red.append((current_title, False, True))

            elif int(verse_n) >= int(verse_start):
                if not found_verse_start:
                    # First verse >= verse_start — show the title that was last seen
                    if current_title:
                        text_with_red.append((current_title, False, True))
                    found_verse_start = True

                is_red = self.red_letter.is_red_letter(book_str, chapter_str, int(verse_n))
                text_with_red.append((f"({verse_n}) {v.text}", is_red, False))

        return text_with_red

    
    




        
        
    
    