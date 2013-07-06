fat = require './lib/fat'
redis = require('then-redis').createClient()



bot = new fat.Bot
  server:   'freenode',
  nick:   process.env.IRC_NICK || 'breza',
  channels: [process.env.IRC_CHANNEL || '#ubuntu-si']

require("./scripts/chatter")(bot)
require("./scripts/getglue")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)
require("./scripts/vreme")(bot)
#require("./scripts/kuki")(bot)
-if process.env.T_CK?
  require("./scripts/novickar")(bot)

bot.command /^.pomo[čc]$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()

process.on "uncaughtException", (err) ->
  try
    bot.say err.toString(), "dz0ny"
  catch e
    console.log err
    console.log e
   
