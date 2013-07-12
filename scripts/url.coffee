is_url = /([a-zA-Z\d]+://)?(\w+:\w+@)?([a-zA-Z\d.-]+\.[A-Za-z]{2,4})(:\d+)?(/.*)?/ig

module.exports = (bot) ->

  bot.on 'user:talk', (r) ->
    if r.text.test is_url
      msg = "#{r.nick}: #{r.text} @#{moment().toString()}"
      redis.rpush("irc:zgodovina", msg)

  bot.regexp /^\.url/i,
  ".url -- Prikaži zadnjih 5 povezav",
  (match, r) ->
    redis.lrange("irc:zgodovina", 0, 4).then (data)->
      for msg in data
        r.reply msg