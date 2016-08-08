# -*- coding: utf-8 -*-
#VERSION: 1.1
#AUTHORS: Davy39 <davy39@hmamail.com>, Danfossi <danfossi@itfor.it>

# Copyleft

import cookielib
import os
import sgmllib
import tempfile
import urllib
import urllib2
import webbrowser

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
        'anime': '',
        'games': '',
        'all': '',
        'movies': 'cat=210&subcat=631',
        'tv': 'cat=210&subcat=433',
        'music': 'cat=395&subcat=623',
        'software': 'cat=233',
        'books': 'cat=404'
    }
    cookie_values = {
        'login': username, 'password': password,
        'remember': '1', 'url': '/'
    }

    def __init__(self):
        self.results = []
        self.parser = self.SimpleSGMLParser(self.results, self.url)

    def _sign_in(self):
        cj = cookielib.CookieJar()
        self.opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
        url_cookie = self.opener.open(self.url + '/users/login/', urllib.urlencode(self.cookie_values))

    def download_torrent(self, url):
        self._sign_in()
        opener = self.opener
        # Open browser if login fail
        try:
            response = opener.open(url)
        except urllib2.URLError as e:
            webbrowser.open(url, new=2, autoraise=True)
            return
        if response.geturl() == url:
            dat = response.read()
            file, path = tempfile.mkstemp(".torrent")
            file = os.fdopen(file, "wb")
            file.write(dat)
            file.close()
            print path + " " + url
        else:
            webbrowser.open(url, new=2, autoraise=True)
            return

    class SimpleSGMLParser(sgmllib.SGMLParser):
        def __init__(self, results, url, *args):
            sgmllib.SGMLParser.__init__(self)
            self.url = url
            self.td_counter = None
            self.current_item = None
            self.results = results

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
        i = 0
        while i < 100:
            results = []
            parser = self.SimpleSGMLParser(results, self.url)
            if cat == 'anime':
                dat = urllib2.urlopen(self.url + '/torrents/search/?cat=210&subcat=455&search=%s&order=seeders&type=desc&page=%d' % (what, i)).read().decode('windows-1252', 'replace')
                dat += urllib2.urlopen(self.url + '/torrents/search/?cat=210&subcat=637&search=%s&order=seeders&type=desc&page=%d' % (what, i)).read().decode('windows-1252', 'replace')
            elif cat == 'games':
                dat = urllib2.urlopen(self.url + '/torrents/search/?cat=624&search=%s&order=seeders&type=desc&page=%d' % (what, i)).read().decode('windows-1252', 'replace')
                dat += urllib2.urlopen(self.url + '/torrents/search/?cat=340&search=%s&order=seeders&type=desc&page=%d' % (what, i)).read().decode('windows-1252', 'replace')
            else:
                dat = urllib2.urlopen(self.url + '/torrents/search/?%s&search=%s&order=seeders&type=desc&page=%d' % (self.supported_categories[cat], what, i)).read().decode('windows-1252', 'replace')
            parser.feed(dat)
            parser.close()
            if len(results) <= 0:
                break
            i += 1
