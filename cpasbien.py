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
            self.data_counter = None
            self.current_item = None
            self.results = results

        def handle_starttag(self, tag, attr):
            method = 'start_' + tag
            if hasattr(self, method) and tag in ('a', 'span', 'td'):
                getattr(self, method)(attr)

        def start_a(self, attr):
            params = dict(attr)
            if params.get('href', '').startswith(self.url + '/dl-torrent'):
                self.current_item = {}
                self.data_counter = 0
                self.current_item["desc_link"] = params["href"].strip()
                # TODO plus joli
                self.current_item["link"] = self.url + '/dl_torrent.php?permalien=' + str(params["href"].strip().split("/")[6].split(".")[0])

        def handle_data(self, data):
            if isinstance(self.data_counter, int):
                self.data_counter += 1
                if self.data_counter == 3:
                    self.current_item["name"] = data.strip()
                elif self.data_counter == 6:
                    self.current_item["size"] = data.strip()
                elif self.data_counter == 9:
                    self.current_item["seeds"] = data.strip()
                elif self.data_counter == 11:
                    self.current_item["leech"] = data.strip()
                    self.current_item["engine_url"] = self.url
                    self.data_counter = None
                    prettyPrinter(self.current_item)
                    self.results.append("a")

    def search(self, what, cat="all"):
        for page in range(35):
            results = []
            parser = self.SimpleHTMLParser(results, self.url)
            data = ''
            for subcat in self.supported_categories[cat]:
                data += retrieve_url(
                    '{}/recherche/{}{}/page-{},trie-seeds-d'
                    .format(self.url, subcat, what, page)
                ).replace(' & ', ' et ')
            results_re = re.compile('(?s)<tbody>.*')
            for match in results_re.finditer(data):
                res_tab = match.group(0)
                parser.feed(res_tab)
                parser.close()
                break
            if len(results) <= 0:
                break
