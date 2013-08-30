is_url = RegExp("^(http|https)://([a-zA-Z0-9_\-]+)([\.][a-zA-Z0-9_\-]+)+([/][a-zA-Z0-9\~\(\)_\-]*)+([\.][a-zA-Z0-9\(\)_\-]+)*$", "ig")
cheerio = require 'cheerio'

resolve = (r)->
  if is_url.test r.text
    default_headers = {
      'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1588.0 Safari/537.36',
    }
    request {
      url: r.text,
      headers: default_headers,
      method: 'GET',
    }, (e, rw, body)->
      console.log e
      if !e and rw.statusCode is 200
        $ = cheerio.load(body)
        naslov = $("title").map (i, el) ->
            return $(this).text()
        opis = $("meta[name=description]").map (i, el) ->
            return $(this).attr("content")
        r.reply "#{naslov}\n#{opis}"
      else
        console.log e

module.exports = (bot) ->

#  bot.on 'user:talk', (r) ->
#   resolve r

  bot.on 'user:talk', (r) ->
    if is_url.test r.text
      msg = "#{r.nick}: #{r.text} @#{moment().toString()}"
      # LPUSH zgodovina "msg"
      # LTRIM zgodovina 0 5
      # LRANGE zgodovina 0 -1
      redis.lpush("irc:zgodovina", msg)
      redis.ltrim("irc:zgodovina", 0, 5)

  bot.regexp /^\.url/i,
  ".url -- Prikaži zadnjih 6 povezav",
  (match, r) ->
    redis.lrange("irc:zgodovina", 0, -1).then (data)->
      for msg in data
        r.reply msg

module.exports.resolve = resolve
