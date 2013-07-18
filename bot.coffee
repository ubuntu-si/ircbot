fat = require './lib/fat'
winston = require('winston')
sentry = require('winston-sentry')

global.logger = new winston.Logger({
    transports: [
        new winston.transports.Console({level: 'silly'}),
        new sentry({
                patchGlobal: true,
                level: 'warn',
                dsn: process.env.DSN
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
redis.info (err, reply) ->
  logger.log err, reply
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
-if process.env.XMPP_PASSWORD?
  require("./scripts/xmpp")(bot)
-if process.env.T_CK?
  require("./scripts/novickar")(bot)

bot.command /^.pomo[čc]$/i, (r) ->
  msg = bot.help.join "\n"
  r.privmsg msg

bot.connect()

