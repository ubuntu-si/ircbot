crypto = require 'crypto'

module.exports = (bot) ->

  bot.regexp /^\.seznam/,
    ".seznam -- Seznam tega kar je v shrambi",
    (match, r) ->
      redis.smembers("irc:set-get:#{crypto.createHash('md5').update(r.nick).digest("hex")}").then (keys)->
        r.reply "#{r.nick}: #{keys}"

  bot.regexp /^\.dobi (.+)/,
    ".dobi <ključ> -- Dobi nekaj iz shrambe",
    (match, r) ->
      key = match[1]
      key = crypto.createHash('md5').update(key+r.nick).digest("hex")
      redis.get("irc:#{key}:shrani").then (data)->
        r.reply "#{r.nick}: #{data}"


  bot.regexp /^\.shrani (.+)/,
    ".shrani <ključ> <sporočilo> -- Shrani nekaj v shrambo",
    (match, r) ->
      key = r.text.replace(".shrani ", "").split(" ")[0]
      keye = crypto.createHash('md5').update(key+r.nick).digest("hex")
      msg = r.text.slice(r.text.indexOf(key)+key.length+1, r.text.length)
      redis.set("irc:#{keye}:shrani", msg).then (data)->
        r.privmsg "Shranjeno! > #{key}:#{msg}"
        redis.sadd("irc:set-get:#{crypto.createHash('md5').update(r.nick).digest("hex")}", key)