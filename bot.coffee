fat = require './lib/fat'
Raven = require 'raven'

if process.env.REDIS_URL?
  global.redis = require('then-redis').createClient(process.env.REDIS_URL)
  Raven.config('https://35574451cc22408db3633f942dc4d0af:cf25dead00cd4a66b6c7e47d18c89e63@sentry.io/147995').install()
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
require("./scripts/forum")(bot)
require("./scripts/wordpress-check")(bot)

bot.command /^.(pomo[čc]|help)$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()
