module.exports = (bot) ->

  is_url = /^(https?):\/\/.+/

  resolve = (url, cb)->
    if is_url.test url
      bot.fetchHTML url, ($)->
        if $
          stack = []
          stack.push $("title").text()
          opis = $("meta[name=description]").attr("content")
          if opis
            stack.push opis
          cb stack.join("\n")

  bot.on 'user:talk', (r) ->
    if is_url.test r.text
      msg = "#{r.text} @#{moment().toString()}"
      redis.rpush("irc:zgodovina:#{r.nick}", msg)
      #resolve r.text, r.reply

  bot.regexp /^\.url (.+)/i,
    ".url <nick> Prikaži urlje, ki jih je objavil <nick>"
    (match, r) ->
      nick = match[1]
      redis.lrange("irc:zgodovina:#{nick}", -5, 5).then (data)->
        for msg in data
          r.reply msg

  bot.regexp /^\.nalozi (.+)/i,
    ".nalozi <url> Prikaži opis in naslov za <url>"
    (match, r) ->
      key = match[1]
      resolve key, r.reply
