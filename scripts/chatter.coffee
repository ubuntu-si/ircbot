moment = require 'moment'
request = require 'request'
cleverbot = require('cleverbot-node')

odgovori_spam_prot = (r, msg)->

  redis.get("irc:antispam").then (anti)->
    console.log anti
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

phrases = [
  "Yes, master?"
  "At your service"
  "Unleash my strength"
  "I'm here. As always"
  "By your command"
  "Ready to work!"
  "Yes, milord?"
  "More work?"
  "Ready for action"
  "Orders?"
  "What do you need?"
  "Say the word"
  "Aye, my lord"
  "Locked and loaded"
  "Aye, sir?"
  "I await your command"
  "Your honor?"
  "Command me!"
  "At once"
  "What ails you?"
  "Yes, my firend?"
  "Is my aid required?"
  "Do you require my aid?"
  "My powers are ready"
  "It's hammer time!"
  "I'm your robot"
  "I'm on the job"
  "You're interrupting my calculations!"
  "What is your wish?"
  "How may I serve?"
  "At your call"
  "You require my assistance?"
  "What is it now?"
  "Hmm?"
  "I'm coming through!"
  "I'm here, mortal"
  "I'm ready and waiting"
  "Ah, at last"
  "I'm here"
  "Something need doing?"
]

snacks = [
  "Om nom nom!",
  "That's very nice of you!",
  "Oh thx, have a cookie yourself!",
  "Thank you very much.",
  "Thanks for the treat!"
]



module.exports = (bot) ->
  c = new cleverbot()

  interv = false
  running = false
  msgs = []
  nickg = false

  poslji = ()=>
    
    skupaj = msgs.join("<br>")
    title = skupaj.slice(0,140).replace("<br>", " ")
    spmj = {
      title:title,
      msg:skupaj,
      nick: nickg
    }
    console.log spmj
    request.post("http://ubuntusilog-node10.rhcloud.com/v1/sporocilo").form(spmj)
    running = false
    msgs = []
    nickg = false

  bot.regexp /^\.stran (.*)/i,
  ".stran <domena> -- Ali stran dela?",
  (match, r) ->
    isUp match[1], (domain) ->
      r.reply domain

  bot.regexp /^\.a (.+)/,
  ".a  <msg> -- ASCIIfy msg",
  (match, r) ->
    ascime match[1], r

  bot.regexp /^breza:? (.+)/,
    (match, r) ->
      data = match[1].trim()
      c.write data, (c) =>
        r.reply c.message

  bot.regexp /^\[?sp\]?:? (.+)/i,
    (match, r) ->
      data = match[1].trim()

      unless nickg
        nickg = r.nick

      msgs.push "<#{r.nick}> #{data}"
      console.log "<#{r.nick}> #{data}"
      clearTimeout interv
      interv = setTimeout poslji, 15000


  bot.regexp /^(zdravo|hi|dan)$/i, (match, r) ->
    hello = random hellos
    r.reply hello.replace "%", r.nick

  bot.regexp /^jutro$/i, (match, r) ->
    hello = random mornings
    r.reply hello.replace "%", r.nick

  bot.regexp /^ping$/i, (match, r) ->
    r.reply random phrases

  bot.regexp /botsnack/i, (match, r) ->
    r.reply random snacks

