xmpp = require('simple-xmpp')

xmpp.connect
  jid: "dz0ny@dukgo.com"
  password: process.env.XMPP_PASSWORD
  host: "dukgo.com"
  port: 5222


module.exports = (bot) ->
  xmpp.on "chat", (from, message) ->
    logger.log "<#{from}> #{message}"
    redis.smembers("irc:xmpp").then (nicks)->
      logger.log "Naročeni: #{nicks}"
      if nicks?   
        for nick in nicks
          bot.say "#{message}", nick

  bot.regexp /^\.im (.+)/i,
    ".im <sporočilo> na slovenski-prevajalci@im.partych.at"
    (match, r) ->
      msg = match[1].trim()
      xmpp.send("slovenski-prevajalci@im.partych.at", msg)  

  bot.command /^\.naročiXMMP$/i,
    ".naročiXMMP -- Prijavi se na slovenski-prevajalci@im.partych.at",
    (r) ->
      redis.sadd("irc:xmpp", r.nick).then (status)->
        r.privmsg "Naročen na slovenski-prevajalci@im.partych.at"
        redis.smembers("irc:xmpp").then (nicks)->
          logger.log "Naročeni: #{nicks}"

  bot.command /^\.odjaviXMMP$/i,
    ".odjaviXMMP -- Odjavi se od slovenski-prevajalci@im.partych.at",
    (r) ->
      redis.srem("irc:xmpp", r.nick).then (status)->
        r.privmsg "Odjavljen od slovenski-prevajalci@im.partych.at"
        redis.smembers("irc:xmpp").then (nicks)->
          logger.log "Naročeni: #{nicks}"