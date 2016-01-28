fs          = require 'fs'
irc         = require 'irc'
sty         = require 'sty'
events      = require 'events'
crypto      = require 'crypto'
global.cheerio = require 'cheerio'
global.request = require 'request'
global._ = require 'underscore'
global.moment = require 'moment'
moment.locale("sl")

defaults =
  server: 'freenode'
  nick: 'lipa'
  username: 'dz0nybot'
  realname: 'dz0nybot, a coffeescript IRC bot'
  port: 6667
  channels: ['#lipa']
  autoConnect: false
  botDebug: false

servers =
  'dalnet': 'irc.dal.net'
  'efnet': 'irc.efnet.net'
  'freenode': 'irc.freenode.net'
  'mozilla': 'irc.mozilla.org'
  'quakenet': 'irc.quakenet.org'
  'undernet': 'us.undernet.org'

class Bot extends events.EventEmitter

  ###
  Constructor
  ###

  sugars = [] # Unused for now

  constructor: (settings, nick, channels) ->

    # Read package.json
    file = fs.readFileSync __dirname + '/../package.json', 'utf-8'
    @package =  JSON.parse file
    @help = ["Pomoč:"]
    if typeof settings is 'string'
      @settings.server = settings
      @settings.nick = nick
      @settings.channels = channels
    else
      @settings = _.extend defaults, settings

    @prepClient()
    @prepEvents()
    @loadExtensions()

    @emit 'self:start',
      client: @client

  toString: () ->
    "#{@package.name}/#{@package.version} node/#{process.versions.node}"

  ###
  Sugars event dispatcher # Unused for now
  ###

  dispatch: (e, r) ->
  for sugar in sugars when sugar.listener is e
    sugar.callback(r)

  ###
  Connect the client
  ###

  connect: ->
    @client.connect()
    return

  ###
  Configure client and Events handlers
  ###

  prepClient: ->
    @settings.server  = if @settings.server of servers then servers[@settings.server] else @settings.server
    @client           = new irc.Client @settings.server, @settings.nick,
      userName: @settings.username
      realName: @settings.realname
      port:     @settings.port
      channels: @settings.channels
      autoConnect: false
      autoRejoin: true
      floodProtection: true
      floodProtectionDelay: 800

  prepEvents: ->
    @client.on 'error', (err) ->
      console.log err
      @emit 'client:error', err

    @client.on 'registered', (msg) =>
      @emit 'self:connected',
        server: msg.server

    @client.on 'message', (from, to, message) =>
      if to isnt @settings.nick
        @emit 'user:talk',
          nick: from
          channel: to
          text: message
          client: @client
          reply: (txt) => @say txt, to
          privmsg: (txt) => @say txt, from

    @client.on 'pm', (from, text, message) =>
      @emit 'user:private',
        nick: from
        text: text
        client: @client
        reply: (txt) => @say txt, from
        privmsg: (txt) => @say txt, from

    @client.on 'join', (channel, nick, message) =>
      if nick is @settings.nick
        @emit 'self:join',
          channel: channel
          nick: nick
          text: message
          client: @client
          say: (txt) => @say txt, channel
      else
        @emit 'user:join',
          channel: channel
          nick: nick
          text: message
          client: @client
          reply: (txt) => @say txt, channel
          privmsg: (txt) => @say txt, nick

  debug: (n,d) ->
    if @settings.botDebug
      console.log "[#{sty.bold 'debug'}](#{sty.red sty.bold n}) #{sty.bold d}"

  ###
  Catch all events
  ###

  emit: (e, params...) ->
    super e, params...
    if e isnt '*'
      @emit '*', e, params...

  on: (e, callback) ->
    if typeof e is 'string'
      super e, callback       # Is native syntax
    else if e.event? and e.trigger?
      @on e.event, e.trigger  # Is object literal syntax
    else
      @on o for o in e        # Is array of objects literal

  ###
  IRC basic interface
  ###

  say: (text, channel) ->
    if channel?
      @client.say channel, text
      @emit 'self:talk',
          channel: channel
          text: text
          client: @client
    else
      for channel in @channels
        @emit 'self:talk',
          channel: channel
          text: text
          client: @client
        @client.say channel, text

  leave: (channel, callback) ->
    if channels in @channels
      @client.part channel, callback
      @channels.pop channel

  join: (channel, callback) ->
    @client.join channel, callback
    @chanels.push channel

###
Built-in extensions
###

Bot::regexp = (regex, pomoc, callback) ->
  if typeof pomoc is "function"
    callback = pomoc
  else
    @help.push pomoc
  ifje = (r)->
    try
      if r.text.match regex
        callback(regex.exec(r.text), r)
    catch e
      console.log e

  @on 'user:private', ifje
  @on 'user:talk', ifje


Bot::command = (regex, pomoc, callback) ->
  if typeof pomoc is "function"
    callback = pomoc
  else
    @help.push pomoc
  ifje = (r)->
    try
      if r.text.match regex
        callback(r)
    catch e
      console.log e

  @on 'user:private', ifje
  @on 'user:talk', ifje

Bot::random = (ar)->
  return ar[Math.floor(Math.random() * ar.length)];

Bot::fetch = (url, cb)->

  ua = [
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.114 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1588.0 Safari/537.36",
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:25.0) Gecko/20100101 Firefox/25.0"
  ]

  default_headers = {
    'User-Agent': @random ua
  }
  request {
    url: url,
    headers: default_headers,
    timeout: 48000,
    method: 'GET',
  }, cb


Bot::fetchJSON = (url, cb)->
  @fetch url, (e, r, body)->
    if !e and r.statusCode is 200
      try
        cb( JSON.parse(body) )
      catch error
        console.log error
    else
      console.log e
      cb false

Bot::fetchJSONCached = (db, time, url, cb)->
  key = "cached:json:#{@keyhash(url)}"
  db.get(key).then (val)=>
    if val
      cb val
    else
      @fetchJSON url, (res)->
        db.setex(key, time, JSON.stringify(res))
        cb res

Bot::keyhash = (data)->
  return crypto.createHash('md5').update(data).digest("hex")

Bot::fetchHTML = (url, cb)->
  @fetch url, (e, r, body)->
    type =  r.headers["content-type"]
    if !e and r.statusCode is 200 and type.indexOf('html') != -1
      cb( cheerio.load(body) )
    else
      cb false

Bot::loadExtensions = ->
  if @settings.botDebug
    @on '*', (e,r) ->
      @debug e r
  @on 'self:start', ->
    version = @toString()
    console.log "[#{sty.bold sty.green version}] I'm #{sty.bold sty.cyan 'loaded'}, ready to connect !"
  @on 'self:connected', (r) ->
    console.log "I'm connected to #{sty.green sty.bold r.server}"
  @on 'self:join', (r) ->
    console.log "I've just joined #{sty.yellow r.channel}"
  @on 'self:talk', (r) ->
    console.log "[#{sty.bold sty.red r.channel}] #{sty.green r.text}"
  @on 'user:private', (r) ->
    console.log "[#{sty.bold sty.red 'private'}] #{sty.green r.nick}: #{r.text}"

module.exports.Bot = Bot
