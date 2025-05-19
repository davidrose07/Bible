import re
from collections import defaultdict

# --- Parse verse references like '5:3-12' or '6:5'
def parse_reference(ref):
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

# --- Build dictionary {chapter: [verses]} for a gospel
def build_red_letter_dict(name, lines):
    red_dict = defaultdict(list)
    for line in lines:
        if line.startswith(name):
            parsed = parse_reference(line)
            if parsed:
                chapter, verses = parsed
                red_dict[chapter].extend(verses)
    return red_dict

# --- Compress verse list into '*list(range(...))' format
def compress_verses(verses):
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

# --- Write compressed dictionary to file
def write_file(name, red_dict):
    output_file = f'{name.lower()}_red_letter.txt'
    with open(output_file, 'w') as f:
        for chapter in sorted(red_dict):
            compressed = compress_verses(red_dict[chapter])
            f.write(f"{chapter}:[{', '.join(compressed)}],\n")

# --- Main execution
if __name__ == "__main__":
    with open("red.txt", "r") as f:
        all_lines = [line.strip() for line in f if line.strip()]

    for gospel in ["Matthew", "Mark", "Luke", "John", "Acts", "1 Corinthian", "2 Corinthian", "Revelation"]:
        red_lines = [line for line in all_lines if line.startswith(gospel)]
        red_dict = build_red_letter_dict(gospel, red_lines)
        write_file(gospel, red_dict)
