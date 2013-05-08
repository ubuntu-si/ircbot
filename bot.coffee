fat = require './lib/fat'
redis = require('then-redis').createClient()

process.on "uncaughtException", (err) ->
  console.log err

bot = new fat.Bot
  server:   'freenode',
  nick:   process.env.IRC_NICK || 'breza2',
  channels: [process.env.IRC_CHANNEL || '#ubuntu-si/']

require("./scripts/chatter")(bot)
require("./scripts/getglue")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)
require("./scripts/vreme")(bot)
-if process.env.T_CK?
  require("./scripts/novickar")(bot)

bot.command /^.pomo[čc]$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()

