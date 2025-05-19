from glob import glob
from os.path import splitext, basename, dirname, join
import xml.etree.ElementTree as ET
from .redletter import RedLetter

TRANSLATIONS_DIR = join(dirname(__file__), "translations")  # Path to the translations directory

import logging, os

## TEMP ##
os.makedirs("logs", exist_ok=True)

# Configure logging
logging.basicConfig(
    filename='logs/app.log',             # log file path
    level=logging.INFO,                  # log level (can be DEBUG, INFO, WARNING, ERROR, CRITICAL)
    format='%(asctime)s - %(levelname)s - %(message)s',
    force=True
)

class Reader:
    def __init__(self):
        """Initialize the Reader object and load available Bible translations into memory."""

        self.red_letter = RedLetter()
        self._load_roots() 
    
    def _load_roots(self):
        """Load root elements for all available translations from XML files."""
        self._current_root = (None, None)  # Initialize the current root as None
        self._roots = {}                   # Dictionary to store root elements by translation
        for ts in self.get_translations():
            self._roots[ts] = self._get_root(ts)

    def _get_root(self, translation_str):
        """Parse the XML file for a given translation and return the root element."""
        return ET.parse("{0}/{1}.xml".format(TRANSLATIONS_DIR, translation_str))

    def set_root(self, translation_str):
        """Set the current root to a specific translation if not already set."""
        if self._current_root[0] == translation_str:
            return
        self._current_root = (translation_str, self._roots[translation_str])

    def get_translations(self):
        """Retrieve a list of available translation names by reading XML files in the translations directory."""
        return [
            splitext(basename(f))[0] for f in glob("{0}/*.xml".format(TRANSLATIONS_DIR))
        ]

    def get_books(self):
        """Return a list of books available in the current translation."""
        return [bel.attrib["n"] for bel in self._current_root[1].findall("b")]

    def get_chapters(self, book_str):
        """Return a list of chapter numbers for a given book in the current translation."""
        return [
            chel.attrib["n"]
            for chel in self._current_root[1]
            .find("b[@n='{0}']".format(book_str))
            .findall("c")
        ]
    

    def get_verses_elements(self, book_str, chapter_str):
        """Retrieve XML elements for all verses in a given book and chapter."""
        return (
            self._current_root[1]
            .find("b[@n='{0}']".format(book_str))
            .find("c[@n='{0}']".format(chapter_str))
            .findall("v")
        )

    def get_verses(self, book_str, chapter_str):
        """Return a list of verse numbers for a specific book and chapter."""
        return [
            vel.attrib["n"] for vel in self.get_verses_elements(book_str, chapter_str)
        ]

    
    
    def get_chapter_text(self, book_str, chapter_str, verse_start=1):
        """Generate the text of a chapter starting from a specific verse with red letter consideration and Title for verses."""
        verses_elements = self.get_verses_elements(book_str, chapter_str)
        text_with_red = []
        for v in verses_elements:
            #if verse n=0 then its a title that needs to be bigger, bold, and centered
            verse_num = int(v.attrib["n"])
            if verse_num == 0:
                text_with_red.append((v.text.strip(), False, True))
            if verse_num >= int(verse_start):
                is_red = self.red_letter.is_red_letter(book_str, chapter_str, verse_num)
                text_with_red.append((f"({verse_num}) {v.text}", is_red, False))
        return text_with_red

        
        
    
    