is_url = RegExp("^http://([a-zA-Z0-9_\-]+)([\.][a-zA-Z0-9_\-]+)+([/][a-zA-Z0-9\~\(\)_\-]*)+([\.][a-zA-Z0-9\(\)_\-]+)*$", "ig")
cheerio = require 'cheerio'

module.exports = (bot) ->

  bot.on 'user:talk', (r) ->
    if r.text.test is_url
      url = r.text
      console.log url
      request.get url, (e, r, body)->
        if !e and r.statusCode is 200
          console.log body
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