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
        redis.expire "yqlqh:#{hash}", 60*8 #8minut
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
      cb "Podatka o vremenu ni..."
vreme2 = (lat, lon, cb) ->

  request.get "http://api.openweathermap.org/data/2.5/weather?APPID=017203dd3aeecf20cfb0b4bc1b032b36&lat=#{lat}&lon=#{lon}", (err, b, res) ->
    unless err
      res = JSON.parse(res)
      vzhod = moment.unix(res.sys.sunrise).format("HH:mm:ss")
      zahod = moment.unix(res.sys.sunset).format("HH:mm:ss")
      t = (res.main.temp-273.15).toFixed(2)
      cb "#{res.name}: #{t}°C, Sončni vzhod: #{vzhod}, Sončni zahod: #{zahod}"
    else
      cb "Podatkov o vremenu ni mogoče pridobiti..."

arso = (key, cb) ->
  request.get "http://maps.googleapis.com/maps/api/geocode/json?address=#{encodeURI(key)},%20slovenija&sensor=true", (err, b, res) ->
    if err
      vreme key, (msg)->
        cb "#{key}: #{msg}"
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
            napoved = data.forecast.data
            if dez is 0
              oblacnost = 0
              deznost = 0
              stej = 0
              cez_dvanajst_ur = moment().add('h', 12)
              sedaj = moment()
              for f in napoved
                """
                  BIG IF, ni ravno šloganje sam vseeeno :)
                """
                if moment(f.forecast_time).isAfter(sedaj) and moment(f.forecast_time).isBefore(cez_dvanajst_ur)
                  oblacnost += f.clouds
                  deznost += f.rain
                  stej++
              if (deznost/stej)>5 and (oblacnost/stej)>5
                msg_toca_dez = "V naslednjih 12 urah je možnost neviht"
              else if (oblacnost/stej)>0
                msg_toca_dez = "V naslednjih 12 urah je predvidena oblačnost"
              else if (deznost/stej)>0
                msg_toca_dez = "V naslednjih 12 urah so možne padavine"
              else
                msg_toca_dez = "V naslednjih 12 urah se obeta stabilno vreme :)"
              
            else
              dezm = switch dez
                when 25 then "Šibke padavine"
                when 50 then "Zmerne padavine"
                when 75 then "Močne padavine"
                when 100 then "Ekstremne padavine"
                else ""

              tocam = switch toca
                when 0 then "zelo majhno"
                when 33 then "zaznavno"
                when 66 then "srednjo"
                when 100 then "veliko"
                else ""
              msg_toca_dez = "#{dezm} z #{tocam} verjetnostjo toče! @#{data.radar.updated_text}"

            ###
              Vremenski radar na Lisci pri Sevnici sproti meri padavine nad Slovenijo in njeno bližnjo okolico.
              Slika prikazuje razporeditev in jakost padavin, izmerjenih vsakih 10 minut.
              Čas meritve je podan v univerzalnem koordiniranem času UTC; ustrezni uradni čas v Sloveniji je za
              eno uro (pozimi) oziroma za dve uri (poleti) večji. Jakost padavin je predstavljena s štirimi razredi:
              šibka (LOW), zmerna (MED), močna (HGH) in ekstremna (EXT) z možno točo.

              Barve označujejo verjetnost, da se ob prikazanem času na obarvanih območjih pojavlja toča 
              (zelena - ZELO MAJHNA, rumena - ZAZNAVNA; oranžna - MED/medium SREDNJA; rdeča - HGH/high VELIKA)

            ###
            yql 'select metData.domain_altitude, metData.t, metData.tsValid_issued, metData.domain_longTitle, metData.domain_lat, metData.domain_lon from xml where url in (select title from atom where url="http://spreadsheets.google.com/feeds/list/0AvY_vCMQloRXdE5HajQxUGF5ZEZYUjhKNG9EeVl2bFE/od6/public/basic")',
              (lokacije)->
                lokacije = lokacije.data
                lokacije.sort (a, b)->
                  a = oddaljenost a.metData.domain_lat, a.metData.domain_lon, loc.lat, loc.lng
                  b = oddaljenost b.metData.domain_lat, b.metData.domain_lon, loc.lat, loc.lng
                  return a - b;
                kraj = _.first(lokacije)
                console.log kraj           
                cb """ARSO: #{kraj.metData.domain_longTitle} (#{kraj.metData.domain_altitude}m): #{kraj.metData.t}°C @#{kraj.metData.tsValid_issued}.\n#{msg_toca_dez}\nhttp://forecast.io/#/f/#{loc.lat},#{loc.lng}"""
                vreme2 loc.lat, loc.lng, (msg)->
                  cb msg
          else
            vreme2 loc.lat, loc.lng, (msg)->
              cb msg
      else
        vreme key, (msg)->
          cb "#{imeg}: #{msg}"


module.exports = (bot) ->
  bot.regexp /^\.vreme (.+)/i,
    ".vreme <kraj> dobi podatke o vremenu za <kraj>"
    (match, r) ->
      key = match[1]
      arso key, (msg)->
        r.reply msg