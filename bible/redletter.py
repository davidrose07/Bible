from typing import Dict, List
from .logs import get_logger

logger = get_logger(__name__)

class RedLetter:
    """
    A class to determine if a Bible verse is considered a 'red-letter' verse (i.e., words spoken by Jesus).
    """
    def __init__(self) -> None:
        """
        Initialize the red_letter_verses dictionary with references to red-letter verses for specific books.
        The data maps book names (lowercase) to a dictionary of chapter numbers and lists of red-letter verse numbers.
        """
        logger.info("Initializing RedLetter Object. . . ")
        self.red_letter_verses: Dict[str, Dict[int, List[int]]] = {
            'matthew': {3:[15],
                        4:[4, 7, 10, 17, 19],
                        5:[*list(range(3,49))],
                        6:[*list(range(1,35))],
                        7:[*list(range(1,28))],
                        8:[*list(range(3,5)), 7, *list(range(10,14)), 20, 22, 26, 32],
                        9:[2, *list(range(4,7)), 9, *list(range(12,14)), *list(range(15,18)), 22, 24, *list(range(28,31)), *list(range(37,39))],
                        10:[*list(range(5,43))],
                        11:[*list(range(4,20)), *list(range(21,31))],
                        12:[*list(range(3,9)), *list(range(11,14)), *list(range(25,38)), *list(range(39,46)), *list(range(48,51))],
                        13:[*list(range(3,10)), *list(range(11,34)), *list(range(37,53)), 57],
                        14:[16, 18, 27, 29, 31],
                        15:[*list(range(3,12)), *list(range(13,15)), *list(range(16,21)), 24, 26, 28, 32, 34],
                        16:[*list(range(2,5)), 6, *list(range(8,12)), 13, 15, *list(range(17,20)), *list(range(23,29))],
                        17:[7, 9, *list(range(11,13)), 17, *list(range(20,24)), *list(range(25,28))],
                        18:[*list(range(3,21)), *list(range(22,36))],
                        19:[*list(range(4,7)), *list(range(8,10)), *list(range(11,13)), 14, *list(range(17,20)), 21, *list(range(23,25)), 26, *list(range(28,31))],
                        20:[*list(range(1,17)), *list(range(18,20)), *list(range(21,24)), *list(range(25,29)), 32],
                        21:[*list(range(2,4)), 13, 16, 19, *list(range(21,23)), *list(range(24,26)), *list(range(27,41)), *list(range(42,45))],
                        22:[*list(range(2,15)), *list(range(18,22)), *list(range(29,33)), *list(range(37,41)), *list(range(42,46))],
                        23:[*list(range(2,40))],
                        24:[2, *list(range(4,52))],
                        25:[*list(range(1,14)), *list(range(31,47))],
                        26:[2, *list(range(10,14)), 18, 21, *list(range(23,30)), *list(range(31,33)), 34, 36, *list(range(38,43)), *list(range(45,47)), 50, *list(range(52,57)), 64],
                        27:[11, 46],
                        28:[*list(range(9,11)), *list(range(18,21))]
                        },

            'mark': {
                1:[15, 17, 25, 38, 41, 44],
                2:[5, *list(range(8,12)), 14, 17, *list(range(19,23)), *list(range(25,29))],
                3:[*list(range(3,6)), *list(range(23,30)), *list(range(33,36))],
                4:[*list(range(3,10)), *list(range(11,33)), 35, *list(range(39,41))],
                5:[*list(range(8,10)), 19, 30, 34, 36, 39, 41],
                6:[4, *list(range(10,12)), 31, *list(range(37,39)), 50],
                7:[*list(range(6,17)), *list(range(18,24)), 27, 29, 34],
                8:[*list(range(2,4)), 5, 12, 15, *list(range(17,22)), *list(range(26,28)), 29, *list(range(33,39))],
                9:[1, *list(range(12,14)), 16, 19, 21, 23, 25, 29, 31, 33, 35, 37, *list(range(39,51))],
                10:[3, *list(range(5,10)), *list(range(11,13)), *list(range(14,16)), *list(range(18,20)), 21, *list(range(23,26)), 27, *list(range(29,32)), *list(range(33,35)), 36, *list(range(38,41)), *list(range(42,46)), *list(range(51,53))],
                11:[*list(range(2,4)), 14, 17, *list(range(22,27)), *list(range(29,31)), 33],
                12:[*list(range(1,12)), *list(range(15,18)), *list(range(24,28)), *list(range(29,32)), *list(range(34,41)), *list(range(43,45))],
                13:[2, *list(range(5,38))],
                14:[*list(range(6,10)), *list(range(13,16)), 18, *list(range(20,23)), *list(range(24,26)), *list(range(27,29)), 30, 32, 34, *list(range(36,39)), *list(range(41,43)), *list(range(48,50)), 62, 72],
                15:[2, 34],
                16:[*list(range(15,19))]

            },

            'luke': {
                2:[49],
                4:[4, 8, 12, *list(range(18,20)), 21, *list(range(23,28)), 35, 43],
                5:[4, 10, *list(range(13,15)), 20, *list(range(22,25)), 27, *list(range(31,33)), *list(range(34,40))],
                6:[*list(range(3,6)), *list(range(8,11)), *list(range(20,50))],
                7:[9, *list(range(13,15)), *list(range(22,29)), *list(range(31,36)), *list(range(40,49)), 50],
                8:[*list(range(5,9)), *list(range(10,19)), *list(range(21,23)), 25, 30, 39, *list(range(45,47)), 48, 50, 52, 54],
                9:[*list(range(3,6)), *list(range(13,15)), 18, 20, *list(range(22,28)), 41, 44, 48, 50, *list(range(55,57)), *list(range(58,61)), 62],
                10:[*list(range(2,17)), *list(range(18,25)), 26, 28, *list(range(30,38)), *list(range(41,43))],
                11:[*list(range(2,14)), *list(range(17,27)), *list(range(28,37)), *list(range(39,45)), *list(range(46,53))],
                12:[*list(range(1,13)), *list(range(14,41)), *list(range(42,60))],
                13:[*list(range(2,10)), 12, *list(range(15,17)), *list(range(18,22)), *list(range(24,31)), *list(range(32,36))],
                14:[3, 5, *list(range(8,15)), *list(range(16,25)), *list(range(26,36))],
                15:[*list(range(4,30))],
                16:[*list(range(1,14)), *list(range(15,32))],
                17:[*list(range(1,5)), *list(range(6,11)), 14, *list(range(17,38))],
                18:[*list(range(2,9)), *list(range(10,15)), *list(range(16,18)), *list(range(19,21)), 22, *list(range(24,26)), 27, *list(range(29,34)), *list(range(41,43))],
                19:[5, *list(range(9,11)), *list(range(12,28)), *list(range(30,32)), 40, *list(range(42,45)), 46],
                20:[*list(range(3,5)), *list(range(8,19)), *list(range(23,26)), *list(range(34,39)), *list(range(41,45)), *list(range(46,48))],
                21:[*list(range(3,5)), 6, *list(range(8,37))],
                22:[3, 8, *list(range(10,13)), *list(range(15,23)), *list(range(25,39)), 40, 42, 46, 48, *list(range(51,54)), 61, *list(range(67,71))],
                23:[*list(range(28,32)), 34, 43, 46],
                24:[17, 19, *list(range(25,27)), 36, *list(range(38,40)), 41, 44, *list(range(46,50))]

            },

            'john': {
                1:[*list(range(38,40)), *list(range(42,44)), *list(range(47,49)), *list(range(50,52))],
                2:[4, *list(range(7,9)), 16, 19],
                3:[3, *list(range(5,9)), *list(range(10,22))],
                4:[7, 10, *list(range(13,15)), *list(range(16,19)), *list(range(21,25)), 26, 32, *list(range(34,39)), 48, 50, 53],
                5:[6, 8, 14, 17, *list(range(19,48))],
                6:[5, 10, 12, 20, *list(range(26,28)), 29, *list(range(32,34)), *list(range(35,41)), *list(range(43,52)), *list(range(53,59)), *list(range(61,66)), 67, 70],
                7:[*list(range(6,9)), *list(range(16,20)), *list(range(21,25)), *list(range(28,30)), *list(range(33,35)), *list(range(37,39))],
                8:[7, *list(range(10,13)), *list(range(14,20)), 21, *list(range(23,27)), *list(range(28,30)), *list(range(31,33)), *list(range(34,48)), *list(range(49,52)), *list(range(54,57)), 58],
                9:[*list(range(3,6)), 7, 35, 37, 39, 41],
                10:[*list(range(1,6)), *list(range(7,19)), *list(range(25,31)), 32, *list(range(34,39))],
                11:[4, *list(range(9,12)), *list(range(14,16)), 23, *list(range(25,27)), 34, *list(range(39,45))],
                12:[*list(range(7,9)), *list(range(23,29)), *list(range(30,33)), *list(range(35,37)), *list(range(44,51))],
                13:[*list(range(7,9)), *list(range(10,22)), *list(range(26,28)), *list(range(31,37)), 38],
                14:[*list(range(1,5)), *list(range(6,8)), *list(range(9,22)), *list(range(23,32))],
                15:[*list(range(1,28))],
                16:[*list(range(1,17)), *list(range(19,29)), *list(range(31,34))],
                17:[*list(range(1,27))],
                18:[*list(range(4,9)), 11, *list(range(20,22)), 23, 34, *list(range(36,38))],
                19:[11, *list(range(26,29)), 30],
                20:[*list(range(15,18)), 19, *list(range(21,24)), *list(range(26,28)), 29],
                21:[*list(range(5,7)), 10, 12, *list(range(15,20)), 22]

            },

            'acts': {
                1:[*list(range(4,6)), *list(range(7,9))],
                9:[*list(range(4,7)), *list(range(10,13)), *list(range(15,17))],
                11:[16],
                18:[*list(range(9,11))],
                20:[35],
                22:[*list(range(7,9)), 10, 18, 21],
                23:[11],
                26:[*list(range(14,19))]
            },

            'revelation':{
                1:[8, 11, *list(range(17,21))],
                2:[*list(range(1,30))],
                3:[*list(range(1,23))],
                16:[15],
                21:[*list(range(5,9))],
                22:[7, *list(range(12,14)), 16, 20]

            }
            
        }

    def is_red_letter(self, book: str, chapter: str, verse: str) -> bool:
        """
        Determine whether a specific verse is a red-letter verse.

        :param book: Name of the book (e.g., 'matthew') in lowercase.
        :param chapter: Chapter number as a string.
        :param verse: Verse number as a string.
        :return: True if the verse is a red-letter verse, False otherwise.
        """
        book = book.lower()
        try:
            chapter= int(chapter)
            verse = int(verse)
        except ValueError:
            return False

        if book in self.red_letter_verses:
            if chapter in self.red_letter_verses[book]:
                if verse in self.red_letter_verses[book][chapter]:
                    return True
        return False

            
    





