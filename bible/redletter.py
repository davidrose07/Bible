
class RedLetter:
    def __init__(self):
        self.red_letter_verses = {
            'matthew': {3: [15], 4: [4, 7, 10, 17, 19], 5: list(range(3, 49)), 6: list(range(1,35)), 7: list(range(1,28)), 8: [3,4,7,10,11,12,13,20,22,26,32], 9:[2,4,5,6,9,12,13,15,16,17,22,24,28,29,30,37], 10: list(range(5,43)), 11: [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,21,22,23,24,25,26,27,28,29,30], 12: [3,4,5,6,7,8,11,12,13,25,26,27,28,29,30,31,32,33,34,35,36,37,39,40,41,42,43,44,45,48,49,50], 13: [3,4,5,6,7,8,9,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,57]},

            'mark': {},

            'luke': {},

            'john': {},

            'acts': {}
        }

    def is_red_letter(self, book, chapter, verse):
        book = book.lower()
        chapter= int(chapter)
        verse = int(verse)

        if book in self.red_letter_verses:
            if chapter in self.red_letter_verses[book]:
                if verse in self.red_letter_verses[book][chapter]:
                    return True
        return False

            
    





