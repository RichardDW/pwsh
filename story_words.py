
"""####!/usr/bin/env python3"""

"""Retrieve and print words from a webpage

Usage:

    python3 story_words.py <URL>
"""

import sys	
from urllib.request import urlopen

def fetch_words(url):
    """Fetch a list of words from an URL

    Args:
        url: The URL of a UTF-9 text document.
        example: http://sixty-north.com/c/t.txt

    Returns:
        A list of strings containing the words from
        the document.
    """
    with urlopen(url) as story:
        story_words = []
        for line in story:
            line_words = line.decode('utf-8').split()
            for word in line_words:
                story_words.append(word)
    return story_words

def print_items(items):
    for item in items:
        print(item)

def main(url):
    words = fetch_words(url)
    print_items(words)

if __name__ == '__main__':
    main(sys.argv[1])





