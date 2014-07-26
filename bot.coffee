fat = require './lib/fat'

console.log process.env

if process.env.REDIS_URL?
  global.redis = require('then-redis').createClient(process.env.REDIS_URL)
else
  global.redis = require('then-redis').createClient()

bot = new fat.Bot
  server:   process.env.IRC_SERVER || 'freenode',
  nick:     process.env.IRC_NICK || 'jabuk',
  channels: [process.env.IRC_CHANNEL || '#ubuntu-si']

require("./scripts/chatter")(bot)
require("./scripts/servisi")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)
require("./scripts/vreme")(bot)
require("./scripts/apt")(bot)
require("./scripts/url")(bot)

bot.command /^.pomo[čc]$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()
