moment = require 'moment'
http = require 'http'
RSS = require 'juan-rss'

module.exports = (bot) ->

  interv = false
  running = false
  msgs = []
  nickg = false

  poslji = ()=>
    
    skupaj = msgs.join("<br>")
    title = skupaj.slice(0,50).replace("<br>", " ")
    spmj = {
      title:title,
      msg:skupaj,
      nick: nickg,
      date: moment()
    }
    redis.lpush("sp_25", JSON.stringify(spmj)).then ->
      redis.ltrim(0, 24).then ->
        console.log "saved an trimmed" 
    running = false
    msgs = []
    nickg = false

  bot.regexp /^\.sp$/i,
  ".sp -- Prikaži zadnjih 5 sporočil prevajalcem",
  (match, r) ->
    redis.lrange("sp25", 0, 4).then (data)->
      for msg in data
        r.reply JSON.parse(msg).skupaj.replace("<br>", "\n")
  
  bot.regexp /^\[?sp\]?:? (.+)/i,
    (match, r) ->
      data = match[1].trim()

      unless nickg
        nickg = r.nick

      msgs.push "<#{r.nick}> #{data}"
      clearTimeout interv
      interv = setTimeout poslji, 15000


ipaddr = process.env.OPENSHIFT_NODEJS_IP or "127.0.0.1"
port = process.env.OPENSHIFT_NODEJS_PORT or 8080
http.createServer((req, res) ->
  res.writeHead 200, "Content-Type": "application/rss+xml"

  rssFeed = new RSS(
    title: "Ubuntu Prevajalci"
    description: "Sporočila za ubuntu prevajalce"
    author: "dz0ny"
  )
  redis.lrange("sp25", 0, -1).then (data)->
    for msg in data
      m = JSON.parse(msg)
      rssFeed.item({
          title           : m.title
        , description     : m.msg
        , url             : 'http://ubuntu.si/log/#date/' + m.date
        , date            : m.date
      })
    res.end rssFeed.xml()
).listen port, ipaddr