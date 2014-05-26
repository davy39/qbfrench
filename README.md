qbfrench
=======
Bunch of qBittorrent search engine for french torrent websites.

Pour me signaler tout problème ou m'indiquer d'autres sites francophones à intégrer, envoyez-moi un mail à **davy39 (arobaz) hmamail (point) com**


Présentation
----------

Ce dépot contient des extentions (plugins) à installer dans le logiciel de téléchargement **qBittorent**.

Ces extensions permettent au moteur de recherche (search engine) intégré à qBittorrent d'effectuer des requettes sur des sites francophones.

A l'heure actuelle (mai 2014), les plugins vous permettent d'effectuer simultanément des recherches de torrents sur les trackers suivants :

### Sites publics 
Aucune autentification n'est requise.

   [Smartorrent](http://www.smartorrent.com)

   [Cpasbien](http://www.cpasbien.pe)

   [Omgtorrent](http://www.omgtorrent.com)

   [TorrentFrancais](http://www.torrentfrancais.com)


### Sites privés 
Nécessite une inscription puis de partager autant de données que vous en téléchargez (upload=download).

   [T411](http://www.t411.me)

Site francophone par excellence, très bien fourni, nombreux pairs, téléchargement rapide.
Si vous n'êtes pas encore inscrits, vous pouvez tout de même installer ce plugin et effetuer des recherches. 
Toutefois, vous ne serez pas autorisés à téléchager.


Installation
-----------

### Affichage du moteur de recherche

Le moteur de recherche de qBitorrent étant optionel, il faut s'assurer qu'il est bien activé.

- Cliquer sur le menu **Affichage** puis sélectionner si nécessaire le **Moteur de recherche**.

- On accède au moteur de recherche en cliquant sur l'onglet **Recherche**, à droite de l'onglet **Transfert**.

### Ajout de nouveaux moteurs de recherche

- Cliquer sur le bouton **Moteur de recherche** situé en bas à droite de l'onglet **Recherche**.

- Cliquer sur le bouton **Installer un nouveau**.


#### Sites publiques :

Cliquer sur le bouton **Lien internet** puis copier/coller l'un des liens suivants en fonction de vos besoins.

**https://raw.githubusercontent.com/davy39/qbfrench/master/cpasbien.py**

**https://raw.githubusercontent.com/davy39/qbfrench/master/smartorrent.py**

**https://raw.githubusercontent.com/davy39/qbfrench/master/omgtorrent.py**

**https://raw.githubusercontent.com/davy39/qbfrench/master/torrentfrancais.py**


#### Sites privés (T411)

- Commencer par télécharger le fichier t411.py en cliquant [ici](https://raw.githubusercontent.com/davy39/qbfrench/master/t411.py)

- Ouvrir le fichier avec un editeur de texte, blocnote, pour renseigner votre identifiant et mot de passe :

```python                                            
username = 'Mon identifiant'                 
password = 'Mon mot de passe'                
```

De la même manière que pour les sites publiques, cliquer sur le bouton **Moteur de recherche** en bas à droite, puis sur **Installer un nouveau**.
Cliquer ensuite sur **Fichier local** pour aller chercher le fichier t411.py que vous avez modifié.