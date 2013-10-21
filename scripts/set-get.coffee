crypto = require 'crypto'

module.exports = (bot) ->

  bot.regexp /^\.seznam/,
    ".seznam -- Seznam tega kar je v shrambi",
    (match, r) ->
      redis.smembers("irc:set-get").then (keys)->
        r.reply "#{r.nick}: #{keys}"

  bot.regexp /^\.shrani (.+)/,
    ".shrani <sporočilo> -- Shrani nekaj v shrambo",
    (match, r) ->
      msg = r.text.replace(".shrani ", "")
      redis.sadd("irc:set-get", "#{r.nick}: #{msg}").then (data)->
        r.privmsg "Shranjeno! > #{r.nick}: #{msg}"
        
