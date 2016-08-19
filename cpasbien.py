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


class cpasbien(object):
    url = "http://www.cpasbien.cm"
    name = "Cpasbien (french)"
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
        self.parser = self.SimpleHTMLParser(self.results, self.url)

    def download_torrent(self, url):
        print(download_file(url))

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results, url, *args):
            HTMLParser.__init__(self)
            self.url = url
            self.div_counter = None
            self.current_item = None
            self.results = results

        def handle_starttag(self, tag, attr):
            method = 'start_' + tag
            if hasattr(self, method) and tag in ('a', 'div'):
                getattr(self, method)(attr)

        def start_a(self, attr):
            params = dict(attr)
            if params.get('href', '').startswith(self.url + '/dl-torrent/'):
                self.current_item = {}
                self.div_counter = 0
                self.current_item["desc_link"] = params["href"]
                fname = params["href"].split('/')[-1]
                fname = re.sub(r'\.html$', '.torrent', fname, flags=re.IGNORECASE)
                self.current_item["link"] = self.url + '/telechargement/' + fname

        def start_div(self, attr):
            if self.div_counter is not None:
                self.div_counter += 1
                # Abort if div class does not match
                div_classes = {1: 'poid', 2: 'up', 3: 'down'}
                attr = dict(attr)
                if div_classes[self.div_counter] not in attr.get('class', ''):
                    self.div_counter = None
                    self.current_item = None

        def handle_data(self, data):
            data = data.strip()
            if data:
                if self.div_counter == 0:
                    self.current_item['name'] = data
                elif self.div_counter == 1:
                    self.current_item['size'] = unit_fr2en(data)
                elif self.div_counter == 2:
                    self.current_item['seeds'] = data
                elif self.div_counter == 3:
                    self.current_item['leech'] = data
            # End of current_item, final validation:
            if self.div_counter == 3:
                required_keys = ('name', 'size')
                if any(key in self.current_item for key in required_keys):
                    self.current_item['engine_url'] = self.url
                    prettyPrinter(self.current_item)
                    self.results.append("a")
                else:
                    pass
                self.current_item = None
                self.div_counter = None

    def search(self, what, cat="all"):
        for page in range(35):
            results = []
            parser = self.SimpleHTMLParser(results, self.url)
            for subcat in self.supported_categories[cat]:
                data = retrieve_url(
                    '{}/recherche/{}{}/page-{},trie-seeds-d'
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
