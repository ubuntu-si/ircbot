fat = require './fat'

bot = new fat.Bot
  server:   'freenode',
  nick:   'breza2',
  channels: ['#ubuntu-si2']

bot.on "self:join", (r)->
  r.say "jutro"

require("./scripts/getglue")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)
require("./scripts/novickar")(bot)

bot.command /^dz0ny dz0ny/i, (r) ->
  r.reply "#{r.nick}: Enkrat bo dovolj, prosim4!"

bot.command /^jutro/i, (r) ->
  r.reply "Jutro #{r.nick} !"

bot.command /^dan/i, (r) ->
  r.reply "Dan #{r.nick} !"

bot.command /^caw/i, (r) ->
  r.reply "Adijo #{r.nick}"

bot.command /^ju+hu+/i, (r) ->
  r.reply "Lepo te je slišati #{r.nick}"

bot.command /^.pomo[čc]/i, (r) ->
  msg = """
  Pomoč:
    .sporoči <nick> <sporočilo> -- Pošlji sporočilo uporabniku, če ni prisoten
    .videl <nick> -- Kdaj je bil uporabnik zadnjič na kanalu, sporočilo
    .vkinu -- Kaj je popularno v kinu (svetovno)
    .natv -- Kaj je popularno na TV (svetovno)
    .film <delni naslov> -- Dobi podatke o filmu
    .tv <delni naslov> -- Dobi podatke o seriji
    .shrani <ključ> <sporočilo> -- Shrani nekaj v shrambo
    .dobi <ključ> -- Dobi nekaj iz shrambe
    .naroči -- Prijavi se na novice 
    .odjavi -- Odjavi se od novic
  """
  r.privmsg msg

bot.connect()