#ubuntu-si irc bot

[![Build Status](https://api.shippable.com/projects/537cbb191cfdf4e401c91a8c/badge/master)](https://www.shippable.com/projects/537cbb191cfdf4e401c91a8c)

Potrebuješ:

 - nodejs
 - redis
 - docker

Preden začneš:

 - ```npm install```

Zaženeš:

 - ```sudo docker build -t dz0ny/ircbot github.com/ubuntu-si/ircbot```
 - ``` sudo docker run -d dz0ny/ircbot```

Tesiraš & razvijaš lokalno:

  - ```./node_modules/.bin/mocha -R spec --compilers coffee:coffee-script test/vreme.coffee``` testiraš specifično funkcionalnost
  - ```npm test``` če želiš kompleten projekt

##Ukazi:

```
Pomoč:
  .vrzi -- Glava ali cifra
  .roll <izbira1,izbira2,...> -- Universe has all the answers
  .ac <?> -- for what
  .plosk -- Zaploskaj
  .ddg -- Vse kar zna https://api.duckduckgo.com/api ali https://api.duckduckgo.com/goodies
  .yt <iskalni niz> -- Išči na youtube
  .sc <iskalni niz> -- Išči na soundcloud
  .calc <enačba> -- Izračunaj
  .asku <pojem> -- Išči po askubuntu, če vsebuje !! potem prikaže povezave
  .stof <pojem> -- Išči po stackoverflow, če vsebuje !! potem prikaže povezave
  .stx <pojem> -- Išči po stackexchange, če vsebuje !! potem prikaže povezave
  .apt <paket> -- Najde pakete po imenu v packages.ubuntu.com
  .pretvori <vrednost> <valuta> <valuta> -- Pretvori med valutami (primer .pretvori 10 eur usd)
  .imdb <naslov> -- Dobi osnovne podatke z IMBD
  .stran <domena> -- Ali stran dela?
  .videl <nick> -- Kdaj je bil uporabnik zadnjič na kanalu, sporočilo
  .sporoči <nick> <sporočilo> -- Pošlji sporočilo uporabniku, če ni prisoten
  .seznam -- Seznam tega kar je v shrambi
  .shrani <sporočilo> -- Shrani nekaj v shrambo
  .vreme <kraj> dobi podatke o vremenu za <kraj>
  .prognoza Vremenska prognoza
  .napoved Vremenska napoved
  .url <nick> Prikaži urlje, ki jih je objavil <nick>
  .nalozi <url> Prikaži opis in naslov za <url>
```
