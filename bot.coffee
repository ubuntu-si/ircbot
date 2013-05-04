fat = require './fat'

bot = new fat.Bot
  server:   'freenode',
  nick:   'breza2',
  channels: ['#ubuntu-si2']

bot.on "self:join", (r)->
  r.say "jutro"

fat.Bot::regexp = (regex,callback) ->
  ifje = (r)->
    try
      if r.text.match regex
        callback(regex.exec(r.text), r)
    catch e
      console.log e
    
  @on 'user:private', ifje
  @on 'user:talk', ifje
    

fat.Bot::command = (regex, callback) ->
  ifje = (r)->
    try
      if r.text.match regex
        callback(r)
    catch e
      console.log e

  @on 'user:private', ifje
  @on 'user:talk', ifje


require("./scripts/getglue")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)

bot.command /^dz0ny dz0ny/i, (r) ->
  r.reply "#{r.nick}: Enkrat bo dovolj, prosim4!"

bot.command /^jutro/i, (r) ->
  r.reply "Jutro #{r.nick} !"

bot.command /l4d2/i, (r) ->
  r.reply "♥ l4d2 ♥"

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
    .dobi <ključ> Dobi nekaj iz shrambe
  """
  r.privmsg msg

bot.connect()