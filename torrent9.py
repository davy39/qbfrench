# -*- coding: utf-8 -*-
#VERSION: 1.1
#AUTHOR: Davy39 <davy39@hmamail.com>
#CONTRIBUTORS: Simon <simon@brulhart.me>

# Copyleft

from __future__ import print_function

import re
try:
    # python2
    from HTMLParser import HTMLParser
except ImportError:
    # python3
    from html.parser import HTMLParser

from helpers import download_file, retrieve_url
from novaprinter import prettyPrinter


class torrent9(object):
    url = "http://www.torrent9.tv"
    name = "Torrent9 (french)"
    supported_categories = {
        "all": [""],
        "books": ["ebook/"],
        "movies": ["films/"],
        "tv": ["series/"],
        "music": ["musique/"],
        "software": ["logiciels/"],
        "games": ["jeux-pc/", "jeux-consoles/"]
    }

    def __init__(self):
        self.results = []
        self.parser = self.SimpleHTMLParser(self.results)

    def download_torrent(self, url):
        print(download_file(url))

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results):
            HTMLParser.__init__(self)
            self.td_counter = None
            self.current_item = None
            self.collect_seeds = False
            self.results = results

        def handle_starttag(self, tag, attr):
            method = 'start_' + tag
            if hasattr(self, method) and tag in ('a', 'span', 'td'):
                getattr(self, method)(attr)

        def start_a(self, attr):
            params = dict(attr)
            if params.get('href', '').startswith('/torrent/') and 'title' in params:
                self.current_item = {}
                self.td_counter = 0
                self.current_item['engine_url'] = torrent9.url
                desc_path = params['href'].strip()
                self.current_item['desc_link'] = torrent9.url + desc_path
                self.current_item['link'] = (
                    torrent9.url
                    + desc_path.replace('/torrent/', '/get_torrent/')
                    + '.torrent'
                )
                m = re.match(
                    u'(?:Télécharger )(.*)(?: en Torrent)', params['title'],
                    flags=re.IGNORECASE
                )
                if m:
                    self.current_item['name'] = m.group(1)
                else:
                    self.current_item['name'] = params['title']  # Fallback

        def start_span(self, data):
            if self.current_item and self.td_counter == 2:
                self.collect_seeds = True

        def start_td(self, data):
            if self.current_item:
                self.td_counter += 1

        def handle_data(self, data):
            if self.current_item and isinstance(self.td_counter, int):
                if self.td_counter == 1 and 'size' not in self.current_item:
                    self.current_item['size'] = unit_fr2en(data.strip())
                elif self.collect_seeds:
                    self.collect_seeds = False
                    self.current_item['seeds'] = data.strip()
                elif self.td_counter == 3 and 'leech' not in self.current_item:
                    self.current_item["leech"] = data.strip()

        def handle_endtag(self, tag):
            if self.current_item and tag == 'tr':
                prettyPrinter(self.current_item)
                self.results.append('a')
                self.current_item = None

    def search(self, what, cat="all"):
        for page in range(35):
            results = []
            parser = self.SimpleHTMLParser(results)
            for subcat in self.supported_categories[cat]:
                data = retrieve_url(
                    '{}/search_torrent/{}{}/page-{},trie-seeds-d'
                    .format(self.url, subcat, what, page)
                )
                parser.feed(data)
            parser.close()
            if len(results) <= 0:
                break


def unit_fr2en(size):
    """Convert french size unit to english"""
    return re.sub(
        r'([KMGTP])o',
        lambda match: match.group(1) + 'B',
        size, flags=re.IGNORECASE
    )
