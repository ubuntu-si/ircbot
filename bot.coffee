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

redis.on "error", (err)->
  console.log err
redis.info (err, reply) ->
  console.log err, reply
bot = new fat.Bot
  server:   'freenode',
  nick:   process.env.IRC_NICK || 'breza',
  channels: [process.env.IRC_CHANNEL || '#ubuntu-si']

require("./scripts/chatter")(bot)
require("./scripts/getglue")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)
require("./scripts/vreme")(bot)
require("./scripts/sp")(bot)
#require("./scripts/url")(bot)
-if process.env.T_CK?
  require("./scripts/novickar")(bot)

bot.command /^.pomo[čc]$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()

process.on "uncaughtException", (err) ->
  console.log err
  try
    bot.say err.toString(), "dz0ny"
  catch e
    console.log err
    console.log e
   
