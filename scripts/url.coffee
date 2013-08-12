is_url = RegExp("^http://([a-zA-Z0-9_\-]+)([\.][a-zA-Z0-9_\-]+)+([/][a-zA-Z0-9\~\(\)_\-]*)+([\.][a-zA-Z0-9\(\)_\-]+)*$", "ig")
cheerio = require 'cheerio'

resolve = (r)->
  if is_url.test r.text
    url = r.text
    request.get url, (e, rw, body)->
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

  bot.on 'user:talk', (r) ->
    resolve r

  bot.on 'user:talk', (r) ->
    if is_url.test r.text
      msg = "#{r.nick}: #{r.text} @#{moment().toString()}"
      redis.rpush("irc:zgodovina", msg)

  bot.regexp /^\.url/i,
  ".url -- Prikaži zadnjih 5 povezav",
  (match, r) ->
    redis.lrange("irc:zgodovina", 0, 4).then (data)->
      for msg in data
        r.reply msg

module.exports.resolve = resolve