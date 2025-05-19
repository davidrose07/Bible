#!/usr/bin/env python3
import re

red_lines = []
with open('app.txt', 'r') as f:
    files = f.readlines()

for file in files:
    matches = re.finditer(r'"(.*?)"', file)

    for match in matches:
        start_index = match.start()
        end_index = match.end()
        
        print("Quoted text: ", match.group(1))            # Without quotes
        print("Full match : ", match.group(0))            # With quotes
        print("Start index:", match.start())              # Index of first quote
        print("End index  :", match.end())                # Index after closing quote
        print("---")