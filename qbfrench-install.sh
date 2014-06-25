#!/bin/bash
# Script d'installtion des extensions de moteur de recherche franophone pour qBittorent


# Déclaration des variables
destination="$HOME/.local/share/data/qBittorrent/nova/engines/"
fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
trap "rm -f $fichtemp" 0 1 2 5 15

### Introduction
function intro ()
{
	dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" \
		--title "Introduction" \
		--no-label "Annuler" --yes-label "Continuer" \
		--colors --yesno "\nBienvenu dans l'installateur \Zb\Z1qbfrench\Zn.\n\nCe script installera des moteurs de recherche français pour \Zb\Z1qBittorent\Zn.\n\nSouhaitez-vous poursuivre l'installation ? " 12 60

	if [ $? = 0 ]
	then 
		choix
	else 
		exit
	fi
}

## Choix des trackers
function choix ()
{
	dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" \
		--title "Sélection des extensions à installer" --clear \
        	--ok-label "Valider" --cancel-label "Quitter" \
        	--colors --checklist "\n- Appuyer sur \Zb\Z1Espace\Zn pour sélectionner les extensions \n\n- Appuyer sur \Zb\Z1Entrée\Zn pour valider votre choix\n\n" 17 60 5 \
		"omgtorrent" "" off\
         	"smartorrent" "" off\
          	"torrentfrancais" "" off\
           	"cpasbien" "" off\
            	"t411" "(privé)" off 2> $fichtemp

	if [ $? = 0 ]
	then

		if [ ! -s $fichtemp ]
			then
			dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" --title "Aucune extension sélectionnée !" \
				--no-label "Annuler" --yes-label "Recommencer" \
				--colors --yesno "Vous n'avez sélectionné aucune extension pour l'installation.
- Déplacez-vous dans la liste avec les flèches \Zb\Z1HAUT\Zn et \Zb\Z1BAS\Zn. 
- Sélectionner une extension avec la barre d'\Zb\Z1ESPACE\Zn.
- Deplacez vous entre \"Valider\" et \"Quitter\" avec les felches \Zb\Z1GAUCHE\Zn et \Zb\Z1DROITE\Zn
- Validez votre choix avec \Zb\Z1ENTREE\Zn
 " 12 60
					if [ $? = 0 ]
					then
						choix
					else
						exit
					fi


		fi
		for choix in `cat $fichtemp`
		do
			instal $choix
		done
		end
	else 
		exit
	fi
}

#### Installation des extensions
function instal ()
{

	if [ $1 = 't411' ]
     	then
		log
	else 
		subst="$1"
		echo "${!subst}" > "$destination$1.py" 
	fi
}    

##### Definition du loggin de T411
function log()
{
	dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" --title "Configuration du compte T411" \
        	--ok-label "Valider" --cancel-label "Quitter" \
		--inputbox "
T411 est un tracker privé, c'est à dire qu'il faut vous créer un compte (gratuit) sur leur site pour avoir accès aux téléchargements.
Pour que le moteur de recherche de qBittorent puisse ajouter les torrents à votre liste de téléchargements, il est nécessaire de le connecter à votre session.

Entrez votre nom d'utilisateur de T411 :" 14 60 user 2> $fichtemp

	if [ $? = 0 ]
	then 
		login=`cat $fichtemp`
		pass 
	else 
		exit
	fi
}

### Definition du mot de passe de T441
function pass()
{
	dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" \
		--title "Configuration du compte T411" \
        	--ok-label "Valider" --cancel-label "Quitter" \
		--insecure --passwordbox "
Pour finaliser l'installation, veuillez renseigner 
votre mot de passe de connection à T411.

Entrez votre mot de passe :" 14 60 2> $fichtemp

	if [ $? = 0 ]
	then 
		password=`cat $fichtemp`
		wget  --quiet --post-data="login=$login&password=$password&remember=1"  --save-cookies=cookies.txt --keep-session-cookies "http://www.t411.me/users/login/" -O log
		test=`cat cookies.txt | grep "pass"`		
		if [ "$test" = '' ]
		then
			reconf
		else
			echo "$t411" | sed "s/my_login/$login/" | sed "s/my_password/$password/" > "$destination""t411.py"
			end
		fi

	else 
		exit
	fi

}

##### Propose la reconfiguration lors de l'erreur de la configuration d'un tracker privé 
function reconf()
{
	dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" --title "Problème d'autentification sur T411" \
	--yes-label "Reconfigurer" --no-label "Terminer" \
	--yesno "
Ooops... La connexion à T411 a échouée.
$
Souhaitez-vous essayer de reconfigurer vos identifiants
ou finaliser l'installation malgré tout ? " 12 60

	if [ $? = 0 ]
	then 
		log
	else 
		end "problem"
	fi
}


##### Fonction d'information de la fin d'installation

function end
{

	if  test -z "$1"
	then
		dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" --title "Bravo, c'est fini !" \
			--sleep 2 --infobox "\nFélicitation, toutes les extensions ont été installées avec succès.\nPensez à redémmarer qBittorent pour que les changements prennent effet." 10 60
	else
		dialog --backtitle "Installation de moteurs de recherche français pour qBittorrent" --title "Bravo, c'est fini !" \
			--sleep 2 --infobox "\nTous les plugins ont été installés.\n\nAttention : T411 semble mal configuré. Dans ce cas qBittorent vous redirigera vers votre navigateur pour télécharger le torrent\nPensez à redémmarer qBittorent pour que les changements prennent effet." 10 60
        
	fi

exit

}


##### Définition des plugins searchengine python

######## Omgtorrent

omgtorrent='# -*- coding: utf-8 -*-
#VERSION: 1.0
#AUTHOR: Davy39 <davy39@hmamail.com>

#Copyleft

from novaprinter import prettyPrinter
import sgmllib, urllib2, tempfile, os

class omgtorrent(object):
  url = "http://www.omgtorrent.com"
  name = "OMGtorrent (french)"
  supported_categories = {"all": ""}
  
  def __init__(self):
    self.results = []
    self.parser = self.SimpleSGMLParser(self.results, self.url)
  
  def download_torrent(self, url):
    file, path = tempfile.mkstemp(".torrent")
    file = os.fdopen(file, "wb")
    dat = urllib2.urlopen(urllib2.Request(url, headers={"User-Agent" : "Mozilla/5.0"} )).read()
    file.write(dat)
    file.close()
    print path+" "+url

  class SimpleSGMLParser(sgmllib.SGMLParser):
    def __init__(self, results, url, *args):
      sgmllib.SGMLParser.__init__(self)
      self.url = url
      self.td_counter = None
      self.current_item = None
      self.results = results
    
    def start_a(self, attr):
      params = dict(attr)
      if params.has_key("href") and params.has_key("class") and params["class"] == "torrent":
	self.current_item = {}
        self.td_counter = 0
        self.current_item["desc_link"]= self.url+params["href"].strip()
        self.current_item["link"] = "http://www.omgtorrent.com/clic_dl.php?groupe=torrents&id="+str(params["href"].strip().split("_")[1].split(".")[0])

    def handle_data(self, data):
      if self.td_counter == 0:  
        if not self.current_item.has_key("name"):
          self.current_item["name"] = data.strip()
      elif self.td_counter == 1:
        if not self.current_item.has_key("size"):
          self.current_item["size"] = data.strip()
      elif self.td_counter == 2:
        if not self.current_item.has_key("seeds"):
          self.current_item["seeds"] = data.strip().replace(",", "")
      elif self.td_counter == 3:
        if not self.current_item.has_key("leech"):
          self.current_item["leech"] = data.strip().replace(",", "")

    def start_td(self,attr):
        if isinstance(self.td_counter,int):
          self.td_counter += 1
          if self.td_counter > 3:
            self.td_counter = None
            self.current_item["engine_url"] = self.url
            prettyPrinter(self.current_item)
            self.results.append("a")

  def search(self, what, cat="all"):
    i = 1
    while i<35:
      results = []
      parser = self.SimpleSGMLParser(results, self.url)
      dat = urllib2.urlopen(urllib2.Request(self.url+"/recherche/?order=seeders&orderby=desc&query=%s&page=%d"%(what, i), headers={"User-Agent" : "Mozilla/5.0"} )).read()
      parser.feed(dat)
      parser.close()
      if len(results) <= 0:
        break
      i += 1'



####### Smarttorrent

smartorrent='# -*- coding: utf-8 -*-
#VERSION: 1.0
#AUTHOR: Davy39 <davy39@hmamail.com>

#Copyleft

from novaprinter import prettyPrinter
import StringIO, gzip, urllib2, tempfile, sgmllib, re, os

class smartorrent(object):
  url = "http://www.smartorrent.com"
  name = "Smartorrent (french)"
  supported_categories = {"all": ["0"],
                          "movies": ["57","49","26","1","37","11","29","39","41","2","18","38","17","25"], 
                          "music": ["54","3"], 
                          "tv": ["33","43","40"], 
                          "anime": ["19","44"], 
                          "games": ["13","20","4","42","14","22","23","28"], 
                          "books": ["5"], 
                          "software": ["12","21","46"] 
                         }
  
  def __init__(self):
    self.results = []
    self.parser = self.SimpleSGMLParser(self.results, self.url)
  
  def download_torrent(self, url):
    opener = urllib2.build_opener(urllib2.BaseHandler())
    file, path = tempfile.mkstemp(".torrent")
    file = os.fdopen(file, "wb")
    dat = opener.open(url).read()
    file.write(dat)
    file.close()

    print path+" "+url
    
  class SimpleSGMLParser(sgmllib.SGMLParser):
    def __init__(self, results, url, *args):
      sgmllib.SGMLParser.__init__(self)
      self.url = url
      self.td_counter = None
      self.current_item = None
      self.results = results
    
    def start_a(self, attr):
      params = dict(attr)
      if params.has_key("href") and params["href"].startswith("http://smartorrent.com/torrent/Torrent-"):
	self.current_item = {}
        self.td_counter = 0
        self.current_item["desc_link"]=params["href"].strip()
        self.current_item["link"] = "http://smartorrent.com/?page=download&tid="+str(params["href"].strip().split("/")[5])

    def handle_data(self, data):
      if self.td_counter == 0:
        if not self.current_item.has_key("name"):
          self.current_item["name"] = data.strip()
      elif self.td_counter == 2:
        if not self.current_item.has_key("size"):
          self.current_item["size"] = data.strip()
      elif self.td_counter == 3:
        if not self.current_item.has_key("seeds"):
          self.current_item["seeds"] = data.strip()
      elif self.td_counter == 4:
        if not self.current_item.has_key("leech"):
          self.current_item["leech"] = data.strip()

    def start_td(self,attr):
        if isinstance(self.td_counter,int):
          self.td_counter += 1
          if self.td_counter > 4:
            self.td_counter = None
            if self.current_item:
              self.current_item["engine_url"] = self.url
              prettyPrinter(self.current_item)
              self.results.append("a")

  def search(self, what, cat="all"):
    opener = urllib2.build_opener(urllib2.BaseHandler())
    ret = []
    i = 1
    while i<35:
      results = []
      parser = self.SimpleSGMLParser(results, self.url)
      dat = ""
      for subcat in self.supported_categories[cat]:
        dat += opener.open(self.url+"/?page=search&term=%s&cat=%s&voir=%d&ordre=sd"%(what, subcat, i)).read().decode("iso-8859-1", "replace").replace("<b><font color=\"#474747\">", "").replace("</font></b>", "")
      parser.feed(dat)
      parser.close()
      if len(results) <= 0:
        break
      i += 1'



###### Torrentfrancais


torrentfrancais='# -*- coding: utf-8 -*-
#VERSION: 1.0
#AUTHOR: Davy39 <davy39@hmamail.com>

# Copyleft

from novaprinter import prettyPrinter
import sgmllib, re, urllib2, os , tempfile, webbrowser

class torrentfrancais(object):
  url = "http://www.torrentfrancais.eu"
  name = "TorrentFrancais (french)"

  def __init__(self):
    self.results = []
    self.parser = self.SimpleSGMLParser(self.results, self.url)

  def download_torrent(self, url):
    # Look for torrent link on descrition page
    link = re.findall("<a href=\"(http://torrents[^\">]*)", urllib2.urlopen(url).read())[0]
    # Try download torrent
    try:
      f = urllib2.urlopen(urllib2.Request(link, headers={"User-Agent" : "Mozilla/5.0"} ))
    except urllib2.URLError as e:
      #Open default webbrowser if  CloudFlare is blocking direct connection (quite often with VPN & proxy...)
      webbrowser.open(link, new=2, autoraise=True)
      return
    if response.getcode() == 200:
      dat = f.read()
      file, path = tempfile.mkstemp(".torrent")
      file = os.fdopen(file, "wb")
      file.write(dat)
      file.close()
      print path+" "+url   
    else:
      #Open default webbrowser if  CloudFlare is blocking direct connection (quite often with VPN & proxy...)
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
      if params.has_key("href") and params.has_key("title") and (params.has_key("class") == False) and params["href"].startswith("http://www.torrentfrancais.eu/torrent/"):
        self.current_item = {}
        self.td_counter = 0
        self.current_item["desc_link"] = params["href"].strip()
	self.current_item["name"] = params["title"].strip()
	self.current_item["link"] = params["href"].strip()

    def start_td(self, attr):
      if isinstance(self.td_counter,int):
	self.td_counter += 1
        if self.td_counter > 7:
          self.td_counter = None
          self.current_item["engine_url"] = self.url
          prettyPrinter(self.current_item)
          self.results.append("a")

    def handle_data(self, data):
        if self.td_counter == 4:
          if not self.current_item.has_key("size"):
            self.current_item["size"] = data.strip()
        if self.td_counter == 6:
          if not self.current_item.has_key("seeds"):
            self.current_item["seeds"] = data.strip()
        if self.td_counter == 7:
          if not self.current_item.has_key("leech"):
            self.current_item["leech"] = data.strip()

  def search(self, what, cat="all"):
    i = 1
    while i<50:
      results = []
      parser = self.SimpleSGMLParser(results, self.url)
      dat = urllib2.urlopen(self.url+"/torrent/%d/%s.html?orderby=seed&ascdesc=desc"%(i, what)).read()
      parser.feed(dat)
      parser.close()
      if len(results) <= 0:
        break
      i += 1'


####### Cpasbien

cpasbien='# -*- coding: utf-8 -*-
#VERSION: 1.0
#AUTHOR: Davy39 <davy39@hmamail.com>

#Copyleft

from novaprinter import prettyPrinter
import urllib2, tempfile, sgmllib, os

class cpasbien(object):
  url = "http://www.cpasbien.pe"
  name = "Cpasbien (french)"
  supported_categories = {"all": "", "books": "ebook/", "movies": "films/", "tv": "series/", "music": "musique/", "software": "logiciels/", "games": ""}
  
  def __init__(self):
    self.results = []
    self.parser = self.SimpleSGMLParser(self.results, self.url)
  
  def download_torrent(self, url):
    file, path = tempfile.mkstemp(".torrent")
    file = os.fdopen(file, "wb")
    dat = urllib2.urlopen(urllib2.Request(url, headers={"User-Agent" : "Mozilla/5.0"} )).read()
    file.write(dat)
    file.close()
    print path+" "+url
    
  class SimpleSGMLParser(sgmllib.SGMLParser):
    def __init__(self, results, url, *args):
      sgmllib.SGMLParser.__init__(self)
      self.url = url
      self.data_counter = None
      self.current_item = None
      self.results = results
    
    def start_a(self, attr):
      params = dict(attr)
      if params.has_key("href") and params["href"].startswith("http://www.cpasbien.pe/dl-torrent"):
	self.current_item = {}
        self.data_counter = 0
        self.current_item["desc_link"]=params["href"].strip()
        self.current_item["link"] = "http://www.cpasbien.pe/dl_torrent.php?permalien="+str(params["href"].strip().split("/")[6].split(".")[0])

    def handle_data(self, data):
	if isinstance(self.data_counter,int):
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
    i = 0
    while i<50:
      results = []
      parser = self.SimpleSGMLParser(results, self.url)
      if cat == "games":
        dat = urllib2.urlopen(urllib2.Request(self.url+"/recherche/jeux-pc/%s/page-%d,trie-seeds-d"%(what, i), headers={"User-Agent" : "Mozilla/5.0"} )).read().replace(" & ", " et ")
        dat += urllib2.urlopen(urllib2.Request(self.url+"/recherche/jeux-consoles/%s/page-%d,trie-seeds-d"%(what, i), headers={"User-Agent" : "Mozilla/5.0"} )).read().replace(" & ", " et ")
      else:
      	dat = urllib2.urlopen(urllib2.Request(self.url+"/recherche/%s%s/page-%d,trie-seeds-d"%(self.supported_categories[cat], what, i), headers={"User-Agent" : "Mozilla/5.0"} )).read().replace(" & ", " et ")
      parser.feed(dat)
      parser.close()
      if len(results) <= 0:
        break
      i += 1'



######## T411


t411='# -*- coding: utf-8 -*-
#VERSION: 1.0
#AUTHOR: Davy39 <davy39@hmamail.com>

# Copyleft

from novaprinter import prettyPrinter
import urllib2, tempfile, sgmllib, os, cookielib, urllib, webbrowser

###################################################
###############!!! CHANGE ME !!!!##################
                                                ###
class t411(object):                             ###
  username = "my_login"                         ###
  password = "my_password"                      ###
                                                ###
###################################################
###################################################

  url = "http://www.t411.me"
  name = "T411 (french - need login)"
  supported_categories = {"anime":"", "games": "", "all": "", "movies": "cat=210&subcat=631", "tv": "cat=210&subcat=433", "music": "cat=395&subcat=623", "software": "cat=233", "books": "cat=404"}
  cookie_values = {"login":username, "password":password, "remember":"1", "url":"/"}

  def __init__(self):
    self.results = []
    self.parser = self.SimpleSGMLParser(self.results, self.url)

  def _sign_in(self):
    cj = cookielib.CookieJar()
    self.opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
    url_cookie = self.opener.open(self.url+"/users/login/", urllib.urlencode(self.cookie_values))

  def download_torrent(self, url):
    self._sign_in()
    opener = self.opener
    #Open browser if login fail
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
      print path+" "+url   
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
      if params.has_key("href") and params["href"].startswith("//www.t411.me/torrents"):
        self.current_item = {}
        self.td_counter = 0
        self.current_item["desc_link"] = "http:" + params["href"].strip()
        self.current_item["name"] = params["title"].strip()
      if params.has_key("href") and params["href"].startswith("/torrents/nfo/"):
        self.current_item["link"] = self.url + params["href"].strip().replace("/torrents/nfo/", "/torrents/download/")
    
    def handle_data(self, data):
      if self.td_counter == 4:
        if not self.current_item.has_key("size"):
          self.current_item["size"] = ""
        self.current_item["size"]+= data.strip()
      elif self.td_counter == 6:
        if not self.current_item.has_key("seeds"):
          self.current_item["seeds"] = ""
        self.current_item["seeds"]+= data.strip()
      elif self.td_counter == 7:
        if not self.current_item.has_key("leech"):
          self.current_item["leech"] = ""
        self.current_item["leech"]+= data.strip()
      
    def start_td(self,attr):
        if isinstance(self.td_counter,int):
          self.td_counter += 1
          if self.td_counter > 7:
            self.td_counter = None
            if self.current_item:
              self.current_item["engine_url"] = self.url
              if not self.current_item["seeds"].isdigit():
                self.current_item["seeds"] = 0
              if not self.current_item["leech"].isdigit():
                self.current_item["leech"] = 0
              prettyPrinter(self.current_item)
              self.results.append("a")

  def search(self, what, cat="all"):
    i = 0
    while i<100:
      results = []
      parser = self.SimpleSGMLParser(results, self.url)
      if cat == "anime":
        dat = urllib2.urlopen(self.url+"/torrents/search/?cat=210&subcat=455&search=%s&order=seeders&type=desc&page=%d"%(what, i)).read().decode("windows-1252", "replace")
        dat += urllib2.urlopen(self.url+"/torrents/search/?cat=210&subcat=637&search=%s&order=seeders&type=desc&page=%d"%(what, i)).read().decode("windows-1252", "replace")
      elif cat == "games":
        dat = urllib2.urlopen(self.url+"/torrents/search/?cat=624&search=%s&order=seeders&type=desc&page=%d"%(what, i)).read().decode("windows-1252", "replace")
        dat += urllib2.urlopen(self.url+"/torrents/search/?cat=340&search=%s&order=seeders&type=desc&page=%d"%(what, i)).read().decode("windows-1252", "replace")
      else:
        dat = urllib2.urlopen(self.url+"/torrents/search/?%s&search=%s&order=seeders&type=desc&page=%d"%(self.supported_categories[cat], what, i)).read().decode("windows-1252", "replace")
      parser.feed(dat)
      parser.close()
      if len(results) <= 0:
        break
      i += 1'

##### Lancement du script ! 

intro


