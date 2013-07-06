fat = require './lib/fat'
http = require 'http'

redis_settings = {
  parser: "javascript"
}

if process.env.OPENSHIFT_REDIS_HOST?
  console.log process.env.OPENSHIFT_REDIS_PORT, process.env.OPENSHIFT_REDIS_HOST, redis_settings
  global.redis = require('then-redis').createClient(process.env.OPENSHIFT_REDIS_PORT, process.env.OPENSHIFT_REDIS_HOST, redis_settings)
  redis.auth process.env.REDIS_PASSWORD
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
#require("./scripts/kuki")(bot)
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
   
