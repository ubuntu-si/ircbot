redis = require('then-redis').createClient()
request = require 'request'
moment = require 'moment'
crypto = require 'crypto'
_ = require 'underscore'



oddaljenost = (lat1, lon1, lat2, lon2) ->
  ## http://mathworld.wolfram.com/SphericalTrigonometry.html
  R = 6371; #v KM
  return Math.acos(Math.sin(lat1)*Math.sin(lat2) + 
                    Math.cos(lat1)*Math.cos(lat2) *
                    Math.cos(lon2-lon1)) * R

yql = (yqlq, cbl) ->
 
  uri = "http://query.yahooapis.com/v1/public/yql?format=json&q=" + encodeURIComponent(yqlq)
  hash = crypto.createHash('md5').update(yqlq).digest("hex")
  redis.get("yqlqh:#{hash}").then (cached)->
    console.log "uri", uri
    unless cached
      request
        uri: uri
      , (error, response, body) ->
        redis.set "yqlqh:#{hash}", body
        redis.expire "yqlqh:#{hash}", 60 * 30 #30minut
        body = JSON.parse(body)
        cbl body.query.results
    else
      cbl JSON.parse(cached).query.results

vreme = (kraj, cb) ->

  yql "select woeid from geo.places where text = \"" + kraj + "\"", (res) ->
    if res
      try
        id = _.first(res.place).woeid
      catch e
        id = res.place.woeid
      
      yql "select item from weather.forecast where woeid = \"" + id + "\"", (res) ->
        item = res.channel.item
        cb "#{(100 / (212 - 32) * (item.condition.temp - 32)).toFixed(2)}°C #{item.link}"
    else
      cb "Kraja ne najdem..."



module.exports = (bot) ->
  bot.regexp /^\.vreme (.+)/i,
    ".vreme <kraj> dobi podatke o vremenu za <kraj>"
    (match, r) ->
      key = match[1]
      request.get "http://maps.googleapis.com/maps/api/geocode/json?address=#{encodeURI(key)},%20slovenija&sensor=true", (err, b, res) ->
        if err
          vreme key, (msg)->
            r.reply "#{key}: #{msg}"
        else
          res = JSON.parse(res)
          krajg = _.first(_.first(res.results).address_components).short_name
          loc = _.first(res.results).geometry.location
          imeg = _.first(res.results).formatted_address
          if (/Slovenia/i).test imeg 
            request.get "http://opendata.si/vreme/report/?lat=#{loc.lat}&lon=#{loc.lng}", (err, b, data) ->
              unless err
                data = JSON.parse(data)
                dez = data.radar.rain_level
                toca = data.hailprob.hail_level
                ###
                  TODO: Malce bolj človeške podatke kaj pomeni dež 33%(rahel dež?)
                ###
                yql 'select two_day_history_url, metData.domain_altitude, metData.rh, metData.t, metData.tsValid_issued, metData.domain_meteosiId, metData.domain_longTitle, metData.domain_lat, metData.domain_lon from xml where url in (select title from atom where url="http://spreadsheets.google.com/feeds/list/0AvY_vCMQloRXdE5HajQxUGF5ZEZYUjhKNG9EeVl2bFE/od6/public/basic")',
                  (lokacije)->
                    lokacije = lokacije.data
                    lokacije.sort (a, b)->
                      a = oddaljenost a.metData.domain_lat, a.metData.domain_lon, loc.lat, loc.lng
                      b = oddaljenost b.metData.domain_lat, b.metData.domain_lon, loc.lat, loc.lng
                      return a - b;
                    kraj = _.first(lokacije)                 
                    r.reply "ARSO: #{kraj.metData.domain_longTitle} (#{kraj.metData.domain_altitude}m): #{kraj.metData.t}°C, Dež:#{dez}%, Možnost toče:#{toca}% @#{kraj.metData.tsValid_issued}"
                    vreme key, (msg)->
                      r.reply "#{imeg}: #{msg}"
              else
                r.reply "Ni podatka za kraj #{krajg} (#{loc.lat},#{loc.lng})"
          else
            vreme key, (msg)->
              r.reply "#{imeg}: #{msg}"