# -*- coding: utf-8 -*-
#VERSION: 1.1
#AUTHORS: Davy39 <davy39@hmamail.com>, Danfossi <danfossi@itfor.it>

# Copyleft

from __future__ import print_function

import os
import tempfile
import webbrowser
try:
    # python2
    import urllib2 as request
    from cookielib import CookieJar
    from HTMLParser import HTMLParser
    from urllib import urlencode
except ImportError:
    # python3
    from urllib import request
    from http.cookiejar import CookieJar
    from html.parser import HTMLParser
    from urllib.parse import urlencode

from helpers import retrieve_url
from novaprinter import prettyPrinter


class t411(object):

###########  !!!!!  CHANGE ME  !!!!!! #############
                                                ###
    # your identifiant on t411.ch:              ###
    username = 'Your_User'                      ###
    # and your password:                        ###
    password = 'Your_Pass'                      ###
                                                ###
###################################################

    domain = 'www.t411.ch'
    url = 'http://{}'.format(domain)
    name = 'T411 (french - need login)'
    supported_categories = {
        'all': [''],
        'anime': ['cat=210&subcat=455', 'cat=210&subcat=637'],
        'games': ['cat=624', 'cat=340'],
        'movies': ['cat=210&subcat=631'],
        'tv': ['cat=210&subcat=433'],
        'music': ['cat=395&subcat=623'],
        'software': ['cat=233'],
        'books': ['cat=404']
    }
    cookie_values = {
        'login': username, 'password': password,
        'remember': '1', 'url': '/'
    }

    def __init__(self):
        self.results = []
        self.parser = self.SimpleHTMLParser(self.results, self.url)

    def _sign_in(self):
        cj = CookieJar()
        self.opener = request.build_opener(request.HTTPCookieProcessor(cj))
        post_params = urlencode(self.cookie_values).encode('utf8')
        url_cookie = self.opener.open(self.url + '/users/login/', post_params)

    def download_torrent(self, url):
        self._sign_in()
        opener = self.opener
        # Open browser if login fail
        try:
            response = opener.open(url)
        except request.URLError as e:
            webbrowser.open(url, new=2, autoraise=True)
            return
        if response.geturl() == url:
            dat = response.read()
            file, path = tempfile.mkstemp(".torrent")
            file = os.fdopen(file, "wb")
            file.write(dat)
            file.close()
            print(path, url)
        else:
            webbrowser.open(url, new=2, autoraise=True)
            return

    class SimpleHTMLParser(HTMLParser):
        def __init__(self, results, url, *args):
            HTMLParser.__init__(self)
            self.url = url
            self.td_counter = None
            self.current_item = None
            self.results = results

        def handle_starttag(self, tag, attr):
            if tag == 'a':
                self.start_a(attr)
            elif tag == 'td':
                self.start_td(attr)

        def start_a(self, attr):
            params = dict(attr)
            if 'href' in params and params['href'].startswith("//{}/torrents".format(t411.domain)):
                self.current_item = {}
                self.td_counter = 0
                self.current_item['desc_link'] = 'http:' + params['href'].strip()
                self.current_item['name'] = params['title'].strip()
            if 'href' in params and params['href'].startswith("/torrents/nfo/"):
                torrent_path = params['href'].strip().replace('/torrents/nfo/', '/torrents/download/')
                self.current_item['link'] = self.url + torrent_path

        def handle_data(self, data):
            if self.td_counter == 4:
                if 'size' not in self.current_item:
                    self.current_item['size'] = ''
                self.current_item['size'] += data.strip()
            elif self.td_counter == 6:
                if 'seeds' not in self.current_item:
                    self.current_item['seeds'] = ''
                self.current_item['seeds'] += data.strip()
            elif self.td_counter == 7:
                if 'leech' not in self.current_item:
                    self.current_item['leech'] = ''
                self.current_item['leech'] += data.strip()

        def start_td(self, attr):
            if isinstance(self.td_counter, int):
                self.td_counter += 1
                if self.td_counter > 7:
                    self.td_counter = None
                    if self.current_item:
                        self.current_item['engine_url'] = self.url
                        if not self.current_item['seeds'].isdigit():
                            self.current_item['seeds'] = 0
                        if not self.current_item['leech'].isdigit():
                            self.current_item['leech'] = 0
                        prettyPrinter(self.current_item)
                        self.results.append('a')

    def search(self, what, cat='all'):
        for page in range(100):
            results = []
            parser = self.SimpleHTMLParser(results, self.url)
            data = ''
            for t411_cat in self.supported_categories[cat]:
                path = ('/torrents/search/?{}&search={}&order=seeders&type=desc&page={}'
                        .format(t411_cat, what, page))
                data += retrieve_url(self.url + path)
            parser.feed(data)
            parser.close()
            if len(results) <= 0:
                break
