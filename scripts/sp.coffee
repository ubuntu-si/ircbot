moment = require 'moment'
RSS = require 'juan-rss'

http = require("http")
express = require("express")

app = express()

app.set "port", process.env.OPENSHIFT_NODEJS_PORT or 8080
app.set "host", process.env.OPENSHIFT_NODEJS_IP or "127.0.0.1"
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.compress()
app.use express.logger("dev")
app.use express.cookieParser()
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public", "dist"))
server = http.createServer(app)

## SOCKET IO
io = sxoket_io.listen(server)
io.enable('browser client minification')  
io.enable('browser client etag')   
io.enable('browser client gzip')      
io.set('log level', 1)  
## ENDOF SOCKET IO

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
  
  bot.on 'user:talk', (r) ->
    io.emit 'user:talk', {nick: r.nick, text: r.text}

  bot.regexp /^\[?sp\]?:? (.+)/i,
    (match, r) ->
      data = match[1].trim()

      unless nickg
        nickg = r.nick

      msgs.push "<#{r.nick}> #{data}"
      clearTimeout interv
      interv = setTimeout poslji, 15000


app.get "/feed", (req, res) ->
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

server.listen app.get("port"), app.get("host")