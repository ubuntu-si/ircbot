redis = require('then-redis').createClient()
moment = require 'moment'
request = require 'request'
moment.lang("sl")


gimdb = (naslov, cb)->
  fetch "http://www.omdbapi.com/?t=#{encodeURI(naslov)}", (data)-> 
    if data
      cb data.imdbRating
    else
      cb "NP"

fixyt = (url)->
  return url.replace("/v/", "/watch?v=")

random = (ar)->
  return ar[Math.floor(Math.random() * ar.length)];

fetch = (url, cb)->
  request.get url, (e, r, body)->

    if !e and r.statusCode is 200
      cb(JSON.parse(body))
    else
      cb false

_get = (api, cb)->
    url = "http://ws.guide.getglue.com/v4/#{api}&token=c817f58e3843bfc50863c1cc5973d53b&app=WebsiteHD"
    fetch url, cb

_object = (api, cb)->

    url = "http://ws.guide.getglue.com/v4/objects/#{api}?token=hOAksHX9QsObO24IbywobRCkMYbDg9yIp7KVp3Cf8Vtf-1617243277&app=WebsiteHD"
    fetch url, cb

vkinu = (cb)->
    _get "guides/suggestions/new_releases?category=new_releases&name=movies_in_theaters&order=relevance&limit=5", (vkinu)->
      if vkinu
        filmi = random(vkinu.items)
        _object filmi.objectKey, (t)->
          gimdb t.title, (imdb)->
            cb "#{t.title} - #{fixyt(t.trailer_link)} [IMDB:#{imdb}] #{t.summary}"

natv = (cb)->
    tv = _get "trending/?category=tv_shows&numItems=10", (vkinu)->
      if vkinu
        filmi = random(vkinu.items)
        _object filmi.objectKey, (t)->
          cb "#{t.title} - #{fixyt(t.trailer_link)} #{t.summary}"

najdifilm = (naslov, cb)->
    tv = _get "search/objects?q=#{encodeURI(naslov)}&category=movies", (vkinu)->
      if vkinu
        _object vkinu.objects[0].id, (t)->
          gimdb t.title, (imdb)->
            cb "#{t.title} (#{t.year})[IMDB:#{imdb}] - #{fixyt(t.trailer_link)} #{t.summary}"

najditv = (naslov, cb)->
    tv = _get "search/objects?q=#{encodeURI(naslov)}&category=tv_shows", (vkinu)->
      if vkinu
        _object vkinu.objects[0].id, (t)->
          cb "#{t.title} - #{t.url} #{t.summary}"
module.exports = (bot) ->

  bot.command /^\.vkinu/i, (r) ->
     vkinu(r.reply)

  bot.command /^\.natv/i, (r) ->
     natv(r.reply)

  bot.regexp /^.film (.+)/, (match, r) ->
    f = match[1]
    najdifilm f, r.reply
  
  bot.regexp /^.tv (.+)/, (match, r) ->
    f = match[1]
    najditv f, r.reply