redis = require('then-redis').createClient()
moment = require 'moment'
request = require 'request'
crypto = require 'crypto'
moment.lang("sl")

module.exports = (bot) ->


  bot.regexp /^.dobi (.+)/, (match, r) ->
    key = match[1]
    key = crypto.createHash('md5').update(key+r.nick).digest("hex")
    redis.get("irc:#{key}:shrani").then (data)->
      r.reply "#{r.nick}: #{data}"

  bot.regexp /^\.shrani (.+)/, (match, r) ->
    key = r.text.replace(".shrani ", "").split(" ")[0]
    keye = crypto.createHash('md5').update(key+r.nick).digest("hex")
    msg = r.text.slice(r.text.indexOf(key)+key.length+1, r.text.length)
    
    redis.set("irc:#{keye}:shrani", msg).then (data)->
      r.privmsg "Shranjeno! > #{key}:#{msg}"