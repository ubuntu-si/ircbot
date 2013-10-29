ddg = require('ddg')
 
random = (ar)->
  return ar[Math.floor(Math.random() * ar.length)];

isUp = (domain, cb) ->
  default_headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux i686; rv:7.0.1) Gecko/20100101 Firefox/7.0.1',
  }
  request {
    url: "http://isitup.org/#{domain.replace(" ", "")}.json",
    headers: default_headers,
    method: 'GET',
  }, (err, res, body) ->
    unless err
      response = JSON.parse(body)
      if response.status_code is 1
        cb "#{response.domain}(#{response.response_ip}) JE dosegljiva."
      else if response.status_code is 2
        cb "#{response.domain}(#{response.response_ip}) NI dosegljiva."
      else if response.status_code is 3
        cb "Si prepričan da je '#{response.domain}' res domena?"
      else
        cb "Neznano za #{response.domain}."
    else
      cb "API limit"


module.exports = (bot) ->


  bot.regexp /^\.stran (.*)/i,
  ".stran <domena> -- Ali stran dela?",
  (match, r) ->
    isUp match[1], (domain) ->
      r.reply domain

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
