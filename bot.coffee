fat = require './fat'

process.on "uncaughtException", (err) ->
  console.log err


bot = new fat.Bot
  server:   'freenode',
  nick:   process.env.IRC_NICK || 'breza2',
  channels: [process.env.IRC_CHANNEL || '#ubuntu-si/']

require("./scripts/getglue")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)

if process.env.T_CK?
  require("./scripts/novickar")(bot)

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

