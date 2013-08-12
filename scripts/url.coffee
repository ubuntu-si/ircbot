is_url = urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g
cheerio = require 'cheerio'

module.exports = (bot) ->

  bot.on 'user:talk', (r) ->
    if r.text.test is_url
      url = r.text
      request.get url, (e, r, body)->
        if !e and r.statusCode is 200
          $ = cheerio.load(body)
          naslov = $("meta title").map (i, el) ->
              return $(this).text()
          opis = $("meta description").map (i, el) ->
              return $(this).text()
          r.reply "#{naslov}\n#{opis}"
        else
          logger.log e
  
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