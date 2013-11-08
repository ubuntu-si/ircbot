ddg = require('ddg')
 
random = (ar)->
  return ar[Math.floor(Math.random() * ar.length)];

module.exports = (bot) ->

  bot.regexp /^ping$/i, (match, r) ->
    r.reply "#{r.nick}: pong"
  
  bot.command /^\.plosk/i,
    ".plosk -- Zaploskaj",
    (r) ->
      r.reply "Chapeau! http://www.youtube.com/watch?v=TAryFIuRxmQ"

  bot.regexp /^\.ddg (.+)/,
    ".ddg -- Vse kar zna https://api.duckduckgo.com/api ali https://api.duckduckgo.com/goodies",
    (match, r) ->
      options =
        useragent: "ubuntu.si"
        no_redirects: "1"
        no_html: "1"

      ddg.query match[1].trim(), options, (err, data) ->
        r.reply data.AbstractText
        r.reply data.Definition
        r.reply data.Answer
        r.reply data.AbstractURL || data.Redirect
