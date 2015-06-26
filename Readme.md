#ubuntu-si irc bot

[![wercker status](https://app.wercker.com/status/26729d8187253b8d033b8545837c49bf/m "wercker status")](https://app.wercker.com/project/bykey/26729d8187253b8d033b8545837c49bf)

Potrebuješ:

 - nodejs
 - redis
 - docker

Preden začneš:

 - ```npm install```

Na Ubuntu 14.04 moraš namestit še
 - ```sudo apt-get install nodejs-legacy```

Zaženeš:

 - ```npm start```

Tesiraš & razvijaš lokalno:

  - ```./node_modules/.bin/mocha -R spec --compilers coffee:coffee-script/register test/vreme.coffee``` testiraš specifično funkcionalnost

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
  .obeti Vremenska napoved za prihodnje dni
  .napoved Vremenska napoved za danes
  .url <nick> Prikaži urlje, ki jih je objavil <nick>
  .nalozi <url> Prikaži opis in naslov za <url>
  .rt -- Izpiše kaj se trenutno predvaja na radioterminal.si
  .morje -- Izpiše temperature slovenskega morja (Koper, Debeli rtič ter Piran)
```
