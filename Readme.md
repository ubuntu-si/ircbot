# ubuntu-si irc bot

[![Build Status](https://travis-ci.org/ubuntu-si/ircbot.svg?branch=master)](https://travis-ci.org/ubuntu-si/ircbot)

Potrebuješ:

 - nodejs

Preden začneš:

 - ```npm install```

Zaženeš:

 - ```npm start```

Tesiraš & razvijaš lokalno:

  - ```./node_modules/.bin/mocha -R spec --compilers coffee:coffeescript/register test/vreme.coffee``` testiraš specifično funkcionalnost

  - ```npm test``` če želiš kompleten projekt

##Ukazi:

```
Pomoč:
  .ac <?> -- for what
  .apt <paket> -- Najde pakete po imenu v packages.ubuntu.com
  .asku <pojem> -- Išči po askubuntu, če vsebuje !! potem prikaže povezave
  .btc <valuta> - Izpiše trenutno BTC vrednost na Bitstamp (na voljo USD, EUR)
  .ddg -- Vse kar zna https://api.duckduckgo.com/api ali https://api.duckduckgo.com/goodies
  .imdb <naslov> -- Dobi osnovne podatke z IMBD
  .morje -- Izpiše temperature slovenskega morja (Koper, Debeli rtič ter Piran)
  .nalozi <url> Prikaži opis in naslov za <url>
  .napoved Vremenska napoved za danes
  .obeti Vremenska napoved za prihodnje dni
  .plosk -- Zaploskaj
  .pretvori <vrednost> <valuta> <valuta> -- Pretvori med valutami (primer .pretvori 10 eur usd)
  .roll <izbira1,izbira2,...> -- Universe has all the answers
  .rt -- Izpiše kaj se trenutno predvaja na radioterminal.si
  .sc <iskalni niz> -- Išči na soundcloud
  .seznam -- Seznam tega kar je v shrambi
  .shrani <sporočilo> -- Shrani nekaj v shrambo
  .sporoči <nick> <sporočilo> -- Pošlji sporočilo uporabniku, če ni prisoten
  .stof <pojem> -- Išči po stackoverflow, če vsebuje !! potem prikaže povezave
  .stran <domena> -- Ali stran dela?
  .stx <pojem> -- Išči po stackexchange, če vsebuje !! potem prikaže povezave
  .url <nick> Prikaži urlje, ki jih je objavil <nick>
  .val -- Izpiše kaj se trenutno predvaja na Val 202
  .videl <nick> -- Kdaj je bil uporabnik zadnjič na kanalu, sporočilo
  .vreme <kraj> dobi podatke o vremenu za <kraj>
  .vrzi -- Glava ali cifra
  .xkcd <parameter> -- Izpiše naslov xkcd stripa in doda povezavo. <parameter>: random - izbere naključni comic, help - izpiše pomoč
  <!-- .yt <iskalni niz> -- Išči na youtube -->
```
