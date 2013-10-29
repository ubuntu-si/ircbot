fat = require './lib/fat'
winston = require('winston')
sentry = require('winston-sentry')

global.logger = new winston.Logger({
    transports: [
        new winston.transports.Console({level: 'silly'}),
        new sentry({
                dsn: "http://34f5e477a2f9431d96fac1e04006ea3d:94020b35b5f34276a0f727ce38216bd3@sentry.radioterminal.si/7"
        })
    ],
})

global.moment = require 'moment'
global.request = require 'request'
moment.lang("sl")
global._ = require 'underscore'

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
  logger.log err
redis.info().then (reply, err) ->
  console.log err, reply

bot = new fat.Bot
  server:   'freenode',
  nick:   process.env.IRC_NICK || 'breza',
  channels: [process.env.IRC_CHANNEL || '#ubuntu-si-offtopic']

require("./scripts/chatter")(bot)
require("./scripts/getglue")(bot)
require("./scripts/seen")(bot)
require("./scripts/set-get")(bot)
require("./scripts/vreme")(bot)
require("./scripts/url")(bot)
#require("./scripts/sp")(bot)
# -if process.env.XMPP_PASSWORD?
#   require("./scripts/xmpp")(bot)
-if process.env.T_CK?
  require("./scripts/novickar")(bot)

bot.command /^.pomo[čc]$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()

process.on "uncaughtException", (err) ->
  
  # handle the error safely
  logger.log err
