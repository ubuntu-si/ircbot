request = require 'request'
_ = require 'underscore'

is_url = /([a-zA-Z\d]+://)?(\w+:\w+@)?([a-zA-Z\d.-]+\.[A-Za-z]{2,4})(:\d+)?(/.*)?/ig

module.exports = (bot) ->

  bot.on 'user:talk', (r) ->
    if r.text.test is_url
      msg = "#{r.nick}: #{r.text} @#{moment().toString()}"
      redis.rpush("irc:zgodovina", msg)

  bot.command /^\.url (.+)/,
    ".url -- Seznam zadnjih 50 povezav",
    (match, r) ->
      r.privmsg "Ni še narejeno"