request = require 'request'
_ = require 'underscore'
youtube = require("youtube-feeds")
youtube.httpProtocol = "https"
moment = require 'moment'
humanize = require 'humanize'
moment.lang("sl")

gimdb = (naslov, cb)->
  fetch "http://www.omdbapi.com/?t=#{encodeURI(naslov)}", (data)-> 
    if data
      cb data.imdbRating
    else
      cb "NP"

fixyt = (url)->
  if url
    return url.replace("/v/", "/watch?v=").replace("&feature=youtube_gdata_player", "")
  else
    return ""

random = (ar)->
  return ar[Math.floor(Math.random() * ar.length)];

yt = (qq, cb) ->
  youtube.feeds.videos
    q: qq
    "max-results": 5
  , (err, data) ->
    unless err
      cb fixyt(_.first(data.items).player.default)
    else
      cb "Ni zadetka"

fetch = (url, cb)->
  request.get url, (e, r, body)->

    if !e and r.statusCode is 200
      console.log body
      cb(JSON.parse(body))
    else
      console.log e
      cb false

_get = (api, cb)->
    url = "http://ws.guide.getglue.com/v4/#{api}&token=c817f58e3843bfc50863c1cc5973d53b&app=WebsiteHD"
    fetch url, cb

_object = (api, cb)->

    url = "http://ws.guide.getglue.com/v4/objects/#{api}?token=hOAksHX9QsObO24IbywobRCkMYbDg9yIp7KVp3Cf8Vtf-1617243277&app=WebsiteHD"
    fetch url, cb

najdifilm = (naslov, cb)->
    _get "search/objects?q=#{encodeURI(naslov)}&category=movies", (data)->
      if data and data.objects.length > 0
        _object _.first(data.objects).id, (t)->
          if t.trailer_link
            cb "#{t.title} (#{t.year}) - #{fixyt(t.trailer_link)} #{t.summary}"
          else
            yt "#{t.title} #{t.director} #{t.year} trailer", (trailer)->
              cb "#{t.title} (#{t.year}) - #{fixyt(trailer)} #{t.summary}"

najditv = (naslov, cb)->
    _get "search/objects?q=#{encodeURI(naslov)}&category=tv_shows", (data)->
      if data and data.objects.length > 0
        _object _.first(data.objects).id, (t)->
          yt "#{t.title} trailer", (trailer)->
            cb "#{t.title} - #{t.trailer} #{t.summary}"

module.exports = (bot) ->

  bot.regexp /^.yt (.+)/,
    ".yt <iskalni niz> -- Išči na youtube",
    (match, r) ->
      f = match[1].trim()
      youtube.feeds.videos
        q: f
        "max-results": 5
      , (err, data) ->
        unless err
          izbran = _.first(data.items)
          r.reply "#{izbran.title}(#{moment.duration(izbran.duration, 'seconds').humanize()}) #{fixyt(izbran.player.default)} ♥#{humanize.numberFormat(izbran.likeCount)} ▶#{humanize.numberFormat(izbran.viewCount)}"
        else
          r.reply "Ni zadetka"

  bot.regexp /^.sc (.+)/,
    ".sc <iskalni niz> -- Išči na soundcloud",
    (match, r) ->
      f = match[1].trim()
      fetch "http://api.soundcloud.com/tracks.json?order=hotness&client_id=93e33e327fd8a9b77becd179652272e2&q=#{encodeURI(f)}", (data) ->
        if data
          izbran = _.first(data)
          r.reply "#{izbran.title}(#{moment.duration(izbran.duration).humanize()}) #{izbran.permalink_url} ♥#{humanize.numberFormat(izbran.favoritings_count)} ▶#{humanize.numberFormat(izbran.playback_count)}"
        else
          r.reply "Ni zadetka"

  bot.regexp /^.film (.+)/,
    ".film <delni naslov> -- Dobi podatke o filmu",
    (match, r) ->
      f = match[1].trim()
      najdifilm f, r.reply
  
  bot.regexp /^.tv (.+)/,
    ".tv <delni naslov> -- Dobi podatke o seriji",
    (match, r) ->
      f = match[1].trim()
      najditv f, r.reply