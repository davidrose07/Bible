import re
from collections import defaultdict
from typing import Optional, Tuple, List, Dict

def parse_reference(ref: str) -> Optional[Tuple[int, List[int]]]:
    """
    Parse a reference string like '5:3-12' or '6:5,7,9-11'.

    :param ref: The reference string to parse.
    :return: A tuple (chapter, list of verse numbers), or None if parsing fails.
    """
    match = re.search(r'(\d+):([\d\-]+)', ref)
    if not match:
        return None
    chapter = int(match.group(1))
    verses = match.group(2)

    result = []
    for part in verses.split(','):
        if '-' in part:
            start, end = map(int, part.split('-'))
            result.extend(range(start, end + 1))
        else:
            result.append(int(part))
    return chapter, result

def build_red_letter_dict(name: str, lines: List[str]) -> Dict[int, List[int]]:
    """
    Build a dictionary of red-letter verses for a specific book.

    :param name: The book name (e.g., 'Matthew').
    :param lines: A list of lines containing verse references.
    :return: Dictionary mapping chapter numbers to lists of verse numbers.
    """
    red_dict = defaultdict(list)
    for line in lines:
        if line.startswith(name):
            parsed = parse_reference(line)
            if parsed:
                chapter, verses = parsed
                red_dict[chapter].extend(verses)
    return red_dict

def compress_verses(verses: List[int]) -> List[str]:
    """
    Compress a list of verses into a compact list-range string format.

    :param verses: List of verse numbers.
    :return: List of strings, either individual numbers or list ranges like '*list(range(3,7))'.
    """
    verses = sorted(set(verses))
    ranges = []
    start = verses[0]
    end = verses[0]

    for v in verses[1:]:
        if v == end + 1:
            end = v
        else:
            ranges.append((start, end))
            start = end = v
    ranges.append((start, end))

    parts = []
    for start, end in ranges:
        if start == end:
            parts.append(f"{start}")
        else:
            parts.append(f"*list(range({start},{end + 1}))")
    return parts

def write_file(name: str, red_dict: Dict[int, List[int]]) -> None:
    """
    Write the compressed red-letter data to a file.

    :param name: The book name (used in the output file name).
    :param red_dict: Dictionary of chapter -> verses.
    """
    output_file = f'{name.lower()}_red_letter.txt'
    with open(output_file, 'w') as f:
        for chapter in sorted(red_dict):
            compressed = compress_verses(red_dict[chapter])
            f.write(f"{chapter}:[{', '.join(compressed)}],\n")

def main() -> None:
    """
    Main execution logic: reads red-letter data from a file and writes formatted files per book.
    """
    with open("red.txt", "r") as f:
        all_lines = [line.strip() for line in f if line.strip()]

    GOSPELS = ["Matthew", "Mark", "Luke", "John", "Acts", "1 Corinthian", "2 Corinthian", "Revelation"]

    for gospel in GOSPELS:
        red_lines = [line for line in all_lines if line.startswith(gospel)]
        red_dict = build_red_letter_dict(gospel, red_lines)
        write_file(gospel, red_dict)

if __name__ == "__main__":
    main()
    
