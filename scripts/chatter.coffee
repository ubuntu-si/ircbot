ddg = require('ddg')

odgovori_spam_prot = (r, msg)->

  redis.get("irc:antispam").then (anti)->
    logger.log anti
    unless anti
      redis.set "irc:antispam", msg
      redis.expire "irc:antispam", 1800
      r.reply msg

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

ascime = (msg, r)->
  request.get "http://asciime.heroku.com/generate_ascii?s=#{encodeURI(msg)}", (err, re, data) ->
    r.reply data

hellos = [
    "Živjo, %",
    "Hej %, lepo te je videti!",
    "Zdravo, %",
    "Dober dan, %",
]
mornings = [
    "Dobro jutro, %",
    "Dobro jutro tudi tebi, %",
]

snacks = [
  "Om nom nom!",
  "Kako lepo od tebe!",
  "Aww, kako si prijazna/en!",
  "Najlepše ti hvala.",
  "Hvala za okusen priboljšek!\nNa še tebi en piškotek!"
]

deletions = [
  "~breza();",
  "delete breza;",
  "del breza",
  "free(breza);",
  "breza = null;",
  "breza = NULL;",
  "breza = nil;",
  "breza = 0;",
  "Segmentation fault (core dumped)"
]



module.exports = (bot) ->

  bot.regexp /^\.stran (.*)/i,
  ".stran <domena> -- Ali stran dela?",
  (match, r) ->
    isUp match[1], (domain) ->
      r.reply domain

  bot.regexp /^\.a (.+)/,
  ".a  <msg> -- ASCIIfy msg",
  (match, r) ->
    ascime match[1], r

  bot.regexp /^\.ubuntu (.+)/,
  ".ubuntu  <msg> -- Ubuntify msg",
  (match, r) ->
    r.reply "While evaluating our options, using the #{match[1]} (or any of its implementations) we concluded that neither approach would allow us to do what we want in the quality that we would like to see for Ubuntu."

  bot.regexp /^(zdravo|hi|dan)$/i, (match, r) ->
    hello = random hellos
    r.reply hello.replace "%", r.nick

  bot.regexp /^jutro$/i, (match, r) ->
    hello = random mornings
    r.reply hello.replace "%", r.nick

  bot.regexp /^ping$/i, (match, r) ->
    r.reply "#{r.nick}: pong"

  bot.regexp /botsnack/i, (match, r) ->
    r.reply random snacks

  bot.regexp /^\.delete/i, (match, r) ->
    r.reply random deletions
  
  bot.command /^\.restart/i,
    ".restart -- Ponovno zaženi",
    (r) ->
      r.nick is "dz0ny"
        r.reply "o/"
        process.exit()
  
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
