# -*- coding: utf-8 -*-
#VERSION: 1.1
#AUTHOR: Davy39 <davy39@hmamail.com>
#CONTRIBUTORS: Simon <simon@brulhart.me>

# Copyleft

from __future__ import print_function

try:
    # python2
    from HTMLParser import HTMLParser
except ImportError:
    # python3
    from html.parser import HTMLParser

from helpers import download_file, retrieve_url
from novaprinter import prettyPrinter


class smartorrent(object):
    url = "http://smartorrent.com"
    name = "Smartorrent (french)"
    supported_categories = {"all": "0"}
    # TODO: Filter general results for specific categories

    def download_torrent(self, url):
        print(download_file(url))

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results):
            HTMLParser.__init__(self)
            self.td_counter = None
            self.next_title = False
            self.next_param = None
            self.current_item = None
            self.results = results

        def handle_starttag(self, tag, attr):
            method = 'start_' + tag
            if hasattr(self, method) and tag in ('a', 'small', 'td'):
                getattr(self, method)(attr)

        def start_a(self, attr):
            params = dict(attr)
            url_prefix = smartorrent.url + '/torrents/'
            if (not params.get('data-toggle', None)
                    and params.get('href', '').startswith(url_prefix)):
                self.current_item = {}
                self.td_counter = 0
                self.current_item['desc_link'] = params['href'].strip()
                torrent_id = params['href'].split(url_prefix)[1]
                self.current_item['link'] = smartorrent.url + '/download/' + torrent_id

        def start_small(self, attr):
            if self.current_item and self.td_counter == 0:
                self.next_title = True

        def handle_data(self, data):
            if self.next_title:
                self.next_title = False
                self.current_item['name'] = data.strip()
            elif self.td_counter == 1:
                if 'size' not in self.current_item:
                    self.current_item['size'] = data.strip()
            elif self.td_counter == 3:
                if 'seeds' not in self.current_item:
                    self.current_item['seeds'] = data.strip()
            elif self.td_counter == 4:
                if 'leech' not in self.current_item:
                    self.current_item['leech'] = data.strip()

        def start_td(self, attr):
            if isinstance(self.td_counter, int):
                self.td_counter += 1
                if self.td_counter > 5:
                    self.td_counter = None
                    if self.current_item:
                        self.current_item["engine_url"] = smartorrent.url
                        prettyPrinter(self.current_item)
                        self.results.append("a")

    def search(self, what, cat="all"):
        for page in range(1, 35):
            results = []
            parser = self.SimpleHTMLParser(results)
            data = retrieve_url(
                self.url + '/search?page={}&search={}'.format(page, what)
            )
            parser.feed(data)
            parser.close()
            if len(results) <= 0:
                break
