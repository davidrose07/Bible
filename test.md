# Bible Project

## Overview

This is a modified version of the [Bible project](https://github.com/rwev/bible), a Python-based application designed to provide a terminal interface for reading and exploring Bible translations. The modifications introduce additional features, fixes, and customization to improve usability and functionality.

## Features

* **Multiple Bible Translations:** Includes support for various Bible translations like NIV, NLT, and more.
* **Terminal User Interface (TUI):** Built with the `curses` library for an interactive terminal-based interface.
* **Red Letter Support:** Identifies and highlights the words of Jesus in red (if supported by the translation).
* **Customizable Translations:** Allows users to add their own Bible translations in XML format.
* **Search and Navigation:** Quickly navigate through books, chapters, and verses.
* **Robust Logging:** Logs errors and app behavior to a rotating log file using Python's `logging` module. All major components now include debug-level function entry logs.
* **Optional Hyphenation:** Attempts to use `PyHyphen==4.0.3` for hyphenation; if unavailable, the app will continue without it.
* **Docker Support:** A Dockerfile is provided for containerized installation and distribution. The container build will not fail if optional dependencies like PyHyphen cannot be installed.
* **Unit Tested:** Includes a growing suite of tests for critical components (reader, red-letter logic, UI).

## Requirements

* Python 3.10
* Recommended to use a virtual environment if setting up locally
* Install dependencies:
* Linux (Debian/Ubuntu preferred)
* Bash shell
* Internet connection (for package installation)

## Setup

* **Docker Setup**
If you're using the Docker setup, a virtual environment is not needed — all dependencies are installed within the container. 
To get started:
```bash
chmod +x install.sh
./install.sh
```
The install file will build and run the docker file.

To run the docker file:
```bash
    docker run -it bible
```
* **Local Setup**
If you're installing locally (without Docker), use the `setup.sh` script to set up the environment and install dependencies:

```bash
chmod +x setup.sh
./setup.sh
```

For local installs, a virtual environment will be created and a `bible` command will be available (via symbolic link) to launch the app. If the setup script fails (e.g., Python 3.10 installation fails or a package is missing), error messages will guide you to resolve the issue and re-run the script.

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
2. Run the install or setup script:

```bash
./install.sh
```
   or:
```bash
./setup.sh
```

## Usage

Run the application using the following command:

Docker:
```bash
docker run -it bible
```

Local
```bash
bible
```

### Adding Translations

To add a new Bible translation:

1. Place the XML file for the translation in the `translations` directory.
2. Ensure the XML file follows the correct format:

   * Root tag: `<bible>`
   * Books: `<b n="BookName">`
   * Chapters: `<c n="ChapterNumber">`
   * Titles: `<v n="0">Title Name</v>`
   * Verses: `<v n="VerseNumber">Verse text</v>`
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

* When verses that require red lettering have Jesus and others talking, use different quote styles (e.g., double quotes for Jesus, single quotes for others) to ensure only Jesus' words are red-lettered.

## Project Structure

```
Bible/
├── bible/
│   ├── __init__.py
│   ├── listwin.py
│   ├── logs.py                # Logging setup
│   ├── logs/                  # Created at runtime
│   ├── main.py                # Main application
│   ├── reader.py
│   ├── redletter.py
│   ├── red_letter_txt/
│   │   ├── parse_red_text.py
│   │   ├── 1 corinthian_red_letter.txt
│   │   ├── 2 corinthian_red_letter.txt
│   │   ├── john_red_letter.txt
│   │   └── red.txt
│   ├── textwin.py
│   └── translations/          # XML translation files go here
├── tests/                     # Unit tests
├── Dockerfile                 # Docker build file
├── install.sh                 # Docker setup + run script
├── setup.sh                   # Local virtualenv install script
├── requirements.txt           # Python dependencies
├── README.md                  # This file
└── LICENSE                    # GPL-3.0 License
```

## Known Issues

* Malformed XML files will result in a runtime error — ensure all translations are valid.
* Verse `n="0"` (used for titles) is not yet included in all translations.
* Case-sensitive book names and mismatched tags may cause display issues.

## Contributing

Contributions are welcome!

## Acknowledgments

* Original project: [rwev/bible](https://github.com/rwev/bible)

## License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0). You can view the full license text in the `LICENSE` file or at [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html).
