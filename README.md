# Bible Project

## Overview
This is a modified version of the [Bible project](https://github.com/rwev/bible), a Python-based application designed to provide a terminal interface for reading and exploring Bible translations. The modifications introduce additional features, fixes, and customization to improve usability and functionality.

## Features
- **Multiple Bible Translations:** Includes support for various Bible translations like NIV, NLT, and more.
- **Terminal User Interface (TUI):** Built with the `curses` library for an interactive terminal-based interface.
- **Red Letter Support:** Identifies and highlights the words of Jesus in red (if supported by the translation).
- **Customizable Translations:** Allows users to add their own Bible translations in XML format.
- **Search and Navigation:** Quickly navigate through books, chapters, and verses.
- **Robust Logging:** Logs errors and usage to a rotating log file using `logging` and `RotatingFileHandler`.
- **Unit Tested:** Includes a growing suite of tests for critical components (reader, red-letter logic, UI).

## Requirements
- Python 3.10
- Recommended to use a virtual environment
- Install dependencies:
- Linux (Debian/Ubuntu preferred)
- Bash shell
- Internet connection (for package installation)

## Setup

Run the provided setup script to install Python, create a virtual environment, and install dependencies:

```bash
chmod +x setup.sh
./setup.sh
```

If successful, a virtual environment will be created in the project directory and a `bible` command will be available globally (via symbolic link) to launch the app.

If the setup script fails (e.g., Python 3.10 installation fails or a package is missing), error messages will guide the user on how to resolve and re-run the script.

## Running Tests

This project includes unit tests for all major components.

```bash
pytest tests/
```

Ensure `pytest` is installed (included in `requirements.txt`).

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/davidorse07/Bible.git
   cd Bible
   ```
2. Run the setup:
   ```bash
   ./setup.sh
   ```

## Usage
Run the application using the following command:
```bash
bible
```

### Adding Translations
To add a new Bible translation:
1. Place the XML file for the translation in the `translations` directory.
2. Ensure the XML file follows the correct format:
   - Root tag: `<bible>`
   - Books: `<b n="BookName">`
   - Chapters: `<c n="ChapterNumber">`
   - Titles: `<v n="0">Title Name</v>`
   - Verses: `<v n="VerseNumber">Verse text</v>`
Example:
```xml
<bible>
  <b n="Matthew">
    <c n="5">
      <v n="0">Add title here</v>
      <v n="1">Verse text here</v>
      <v n="2">Another verse...</v>
    </c>
  </b>
</bible>
```
Known Issues:
   - When verses that require red lettering have Jesus and others talking you have to separate Jesus' quotes(") and others(') to only red letter Jesus' phrases

## Project Structure
```
Bible/
├── bible/
│   ├── __init__.py
│   ├── main.py            # Main application entry point
│   ├── reader.py          # Parses and loads XML translations
│   ├── redletter.py       # Red-letter detection logic
│   ├── listwin.py         # Selectable list UI component
│   ├── textwin.py         # Text rendering component
│   ├── logs.py            # Centralized logging setup
│   ├── translations/      # XML translations
│   ├── red_letter_txt/
│   │   ├── red.txt        # Source red-letter references
│   │   └── parse_red_text.py  # Builds red-letter data files
├── tests/                 # Unit tests
├── requirements.txt       # Python dependencies
├── setup.sh               # Automated setup script
├── run_bible.sh           # Script to launch the app via virtualenv
├── README.md              # This file
└── LICENSE                # GPL-3.0 License
```

## Known Issues
- Malformed XML files will result in a runtime error — ensure all translations are valid.
- Verse `n="0"` (used for titles) is not yet included in all translations.
- Case-sensitive book names and mismatched tags may cause display issues.

## Contributing
Contributions are welcome! 

## Acknowledgments
- Original project: [rwev/bible](https://github.com/rwev/bible)

## License
This project is licensed under the GNU General Public License v3.0 (GPL-3.0). You can view the full license text in the `LICENSE` file or at [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html).
