fat = require './lib/fat'

if process.env.OPENSHIFT_REDIS_HOST?
  global.redis = require('then-redis').createClient({
    host: process.env.OPENSHIFT_REDIS_HOST,
    port: process.env.OPENSHIFT_REDIS_PORT,
    database: 1,
    password: process.env.REDIS_PASSWORD
  })
else
  global.redis = require('then-redis').createClient()

bot = new fat.Bot
  server:   'freenode',
  nick:   'jabuk',
  channels: ['#ubuntu-si']

require("./scripts/chatter")(bot)
require("./scripts/servisi")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)
require("./scripts/vreme")(bot)
require("./scripts/apt")(bot)
require("./scripts/url")(bot)
-if process.env.T_CK?
  require("./scripts/novickar")(bot)

bot.command /^.pomo[čc]$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()

process.on "uncaughtException", (err) ->
  
  # handle the error safely
  console.log err
