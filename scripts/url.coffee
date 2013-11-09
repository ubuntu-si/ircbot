module.exports = (bot) ->

  is_url = /^(https?):\/\/.+/

  resolve = (url, cb)->
    if is_url.test url
      bot.fetchHTML url, (e, $)->
        if $? and not e
          naslov = $("title").map (i, el) ->
              return $(this).text()
          opis = $("meta[name=description]").map (i, el) ->
              return $(this).attr("content")
          cb "#{naslov}\n#{opis}"
        else
          cb "Ni HTML"
    else
      cb "Ni URL"

  bot.on 'user:talk', (r) ->
    if is_url.test r.text
      msg = "#{r.text} @#{moment().toString()}"
      redis.rpush("irc:zgodovina:#{r.nick}", msg)

  bot.regexp /^\.url (.+)/i,
    ".url <nick> Prikaži urlje, ki jih je objavil <nick>"
    (match, r) ->
      nick = match[1]
      redis.lrange("irc:zgodovina:#{nick}", 0, 5).then (data)->
        for msg in data
          r.reply msg

  bot.regexp /^\.nalozi (.+)/i,
    ".nalozi <url> Prikaži opis in naslov za <url>"
    (match, r) ->
      key = match[1]
      resolve key, r.reply
