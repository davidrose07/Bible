#!/bin/bash
cd "$HOME/Bible" || exit 1
source "$HOME/Bible/venv/bin/activate"
pip install -e .  # ensures the 'bible' package is available
python -m bible.main
deactivate
