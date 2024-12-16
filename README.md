# Bible Project

## Overview
This is a modified version of the [Bible project](https://github.com/rwev/bible), a Python-based application designed to provide a terminal interface for reading and exploring Bible translations. The modifications introduce additional features, fixes, and customization to improve usability and functionality.

## Features
- **Multiple Bible Translations:** Includes support for various Bible translations like NIV, NLT, and more.
- **Terminal User Interface (TUI):** Built with the `curses` library for an interactive terminal-based interface.
- **Red Letter Support:** Identifies and highlights the words of Jesus in red (if supported by the translation).
- **Customizable Translations:** Allows users to add their own Bible translations in XML format.
- **Search and Navigation:** Quickly navigate through books, chapters, and verses.

## Requirements
- Python 3.10 or later
- Required Python libraries:
  - `curses`
  - `xml.etree.ElementTree`

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/davidorse07/Bible.git
   cd Bible
   ```
2. Install dependencies (if any):
   ```bash
   pip install -r requirements.txt
   ```

## Usage
Run the application using the following command:
```bash
python3 -m bible.main
```

### Adding Translations
To add a new Bible translation:
1. Place the XML file for the translation in the `translations` directory.
2. Ensure the XML file follows the correct format:
   - Root tag: `<bible>`
   - Books: `<b n="BookName">`
   - Chapters: `<c n="ChapterNumber">`
   - Verses: `<v n="VerseNumber">Verse text</v>`

## Project Structure
```
Bible/
├── bible/
│   ├── __init__.py
│   ├── main.py          # Entry point for the application
│   ├── reader.py        # Handles parsing and data retrieval
│   ├── redletter.py     # Manages red-letter text functionality
│   ├── translations/    # Contains Bible translation XML files
│   └── ...
├── requirements.txt     # List of Python dependencies
├── LICENSE              # License for the project
├── README.md            # Project documentation
└── ...
```

## Known Issues
- Ensure XML files are well-formed; malformed files may cause parsing errors.
- Some features rely on consistent attribute naming (e.g., `n="..."`), so discrepancies may lead to bugs.

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch.
3. Submit a pull request with detailed information about your changes.

## Acknowledgments
- Original project: [rwev/bible](https://github.com/rwev/bible)

## License
This project is licensed under the GNU General Public License v3.0 (GPL-3.0). You can view the full license text in the `LICENSE` file or at [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html).

