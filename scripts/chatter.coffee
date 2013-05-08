redis = require('then-redis').createClient()
moment = require 'moment'

odgovori_spam_prot = (r, msg)->

  redis.get("irc:antispam").then (anti)->
    console.log anti
    unless anti
      redis.set "irc:antispam", msg
      redis.expireat "irc:antispam", moment().add("hours", 1).unix()
      r.reply msg

module.exports = (bot) ->

  bot.command /^jutro$/i, (r) ->
      odgovori_spam_prot r, "Jutro #{r.nick} !"

  bot.command /^dan$/i, (r) ->
    odgovori_spam_prot r, "Dan #{r.nick} !"

  bot.command /^caw$/i, (r) ->
    odgovori_spam_prot r, "Adijo #{r.nick}"

  bot.command /^ju+hu+$/i, (r) ->
    odgovori_spam_prot r, "Lepo te je slišati #{r.nick}"