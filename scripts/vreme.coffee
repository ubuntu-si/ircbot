crypto = require 'crypto'
suncalc = require 'suncalc'
cheerio = require 'cheerio'

module.exports = (bot) ->

  arsoAvto = (re)->
    ArsoPotresi (pots)->
      for tpm in pots
        ((pot, r)->
          if Number(pot.m) > 1
            redis.get("irc:#{pot.date}:potres").then (posted)->
              if !posted
                redis.set("irc:#{pot.date}:potres", true)
                r "M #{pot.m} > #{pot.loc} @#{pot.date}  https://maps.google.com/?q=#{pot.lat}+N,+#{pot.lon}+E"
              else
                return
        )(tpm, re)

  ArsoPotresi = (cb)->
    bot.fetchJSON "http://potresi.herokuapp.com/potresi.json", (data)->
      apotresi = []
      try
        for e in data
          if e.Magnituda > 0
            apotresi.push {
              date: e.Datum,
              lat: e.Lat,
              lon: e.Lon,
              m: e.Magnituda,
              loc: e.Lokacija,
            }
      catch error
        console.log error

      cb apotresi

  interval = 0
  bot.on "self:join", (r)->
    clearInterval interval
    interval = setInterval ()->
      arsoAvto(r.say)
    ,1000*60

  oddaljenost = (lat1, lon1, lat2, lon2) ->
    ## http://mathworld.wolfram.com/SphericalTrigonometry.html
    R = 6371; #v KM
    return Math.acos(Math.sin(lat1)*Math.sin(lat2) +
                      Math.cos(lat1)*Math.cos(lat2) *
                      Math.cos(lon2-lon1)) * R

  yql = (yqlq, cbl) ->

    cached_time = 15 * 60 #15min
    uri = "http://query.yahooapis.com/v1/public/yql?format=json&q=" + encodeURIComponent(yqlq)
    bot.fetchJSONCached redis, cached_time, uri, (res) ->
      cbl res.query.results


  vreme = (kraj, cb) ->

    yql "select woeid from geo.places where text = \"" + kraj + "\"", (res) ->
      if res?
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
    secondsTimeSpanToHMS = (s) ->
      h = Math.floor(s / 3600) #Get whole hours
      s -= h * 3600
      m = Math.floor(s / 60) #Get remaining minutes
      s -= m * 60
      h + "ur " + ((if m < 10 then "0" + m else m)) + "min " + ((if s < 10 then "0" + s else s)) #zero padding on minutes and seconds

    time = suncalc.getTimes(new Date, lat, lon)
    vzhod = moment(time.sunrise).format("HH:mm:ss")
    zahod = moment(time.sunset).format("HH:mm:ss")
    kulminacija = moment(time.solarNoon).format("HH:mm:ss")
    dolg = moment.duration(moment(time.sunset).diff(moment(time.sunrise)))/1000
    if suncalc.getMoonIllumination(new Date) == 0
      luna = "Prazna luna"
    else if suncalc.getMoonIllumination(new Date) == 1
      luna = "Polna luna"
    else
      luna = "Luna je v ščipu"

    msg = "Sončni vzhod: #{vzhod}, Kulminacija: #{kulminacija}, Sončni zahod: #{zahod}\nDan je dolg: #{secondsTimeSpanToHMS(dolg.toFixed(0))}s, #{luna}"
    cb msg


  arso = (key, cb) ->
    cached_time_geo = 356 * 24 * 60 * 60 #1 leto
    url_geo = "http://maps.googleapis.com/maps/api/geocode/json?address=#{encodeURI(key)},%20slovenija&sensor=true"
    bot.fetchJSONCached redis, cached_time_geo, url_geo, (res) ->
      unless res # ne najde kraja
        vreme key, (msg)->
          cb "#{key}: #{msg}"
      else #najde kraj
        try
          krajg = _.first(_.first(res.results).address_components).short_name
          loc = _.first(res.results).geometry.location
          imeg = _.first(res.results).formatted_address
          if (/Slovenia/i).test imeg
            bot.fetchJSON "http://potresi.herokuapp.com/postaje.json", (lokacije)->
              lokacije.sort (a, b)->
                a = oddaljenost a.Lat, a.Lon, loc.lat, loc.lng
                b = oddaljenost b.Lat, b.Lon, loc.lat, loc.lng
                return a - b;
              kraj = _.first(lokacije)
              if (kraj.WindDirection)
                switch kraj.WindDirection
                  when 'N' then veter = "severnik"
                  when 'S' then veter = "južni veter"
                  when 'E' then veter = "vzhodnik"
                  when 'W' then veter = "zahodnik"
                  when 'NE' then veter = "severovzhodnik"
                  when 'NW' then veter = "severozahodnik"
                  when 'SE' then veter = "jugovzhodnik"
                  when 'SW' then veter = "jugozahodnik"
                  else veter = ""
              else
                veter = ""
              hitrost_vetra = if (kraj.Wind) then "#{kraj.Wind}" else ""
              veter = "#{veter} #{if (hitrost_vetra) then """#{hitrost_vetra} m/s (#{ (hitrost_vetra * 3.6).toFixed(1)} km/h)""" else ''}"
              vlaznost = if (kraj.RH) then "Vlažnost: #{kraj.RH}%" else ""
              oblacnost = if (kraj.Sky) then kraj.Sky else ""
              vreme2 loc.lat, loc.lng, (msg)->
                cb """ARSO: #{kraj.Title} (#{kraj.Altitude}m): #{kraj.Temp}°C @#{kraj.Valid}.\n#{vlaznost} #{veter} #{oblacnost}\n""" + msg
          else
            vreme key, (msg)->
              cb "#{imeg}: #{msg}"
        catch e
          cb "Neznana lokacija"

  bot.regexp /^\.potres$/i,
    ".potres prikazi zadnji potres"
    (match, r) ->
      ArsoPotresi (msg)->
        msg = msg[0]
        r.reply "M #{msg.m} > #{msg.loc} @#{msg.date}  https://maps.google.com/?q=#{msg.lat}+N,+#{msg.lon}+E"

  bot.regexp /^\.potresi$/i,
    ".potresi prikazi zadnji potres večji od M1"
    (match, r) ->
      msg = ""
      ArsoPotresi (pots)->
        for pot in pots
          if Number(pot.m) > 1
            msg += "M #{pot.m} > #{pot.loc} @#{pot.date}  https://maps.google.com/?q=#{pot.lat}+N,+#{pot.lon}+E"
            break
        r.reply msg
  bot.regexp /^\.vreme (.+)/i,
    ".vreme <kraj> dobi podatke o vremenu za <kraj>"
    (match, r) ->
      key = match[1]
      arso key, (msg)->
        r.reply msg

  bot.command /^\.obeti/i,
    ".obeti Vremenska napoved za prihodnje dni"
    (r) ->
      url = "http://meteo.arso.gov.si/uploads/probase/www/fproduct/text/sl/fcast_si_text.html"
      bot.fetchHTML url, ($)->
        if $?
          vsebina = $("td.vsebina")
          obeti = $(vsebina).toString().substring($(vsebina).toString().lastIndexOf('<h2>OBETI</h2>') + 1, $(vsebina).toString().lastIndexOf('<h2>VREMENSKA SLIKA</h2>'))
          r.reply $(obeti).text().replace(/h2>OBETI/g,'')
        else
          r.reply "Podatka o vremenu ni..."

  bot.command /^\.napoved/i,
    ".napoved Vremenska napoved za danes"
    (r) ->
      url = "http://meteo.arso.gov.si/uploads/probase/www/fproduct/text/sl/fcast_si_text.html"
      bot.fetchHTML url, ($)->
        if $?
          vsebina = $("td.vsebina")
          napoved = $(vsebina).toString().substring($(vsebina).toString().lastIndexOf('<h2>NAPOVED ZA SLOVENIJO</h2>') + 1, $(vsebina).toString().lastIndexOf('<h2>OBETI</h2>'))
          r.reply $(napoved).text().replace(/h2>NAPOVED ZA SLOVENIJO/g,'')
        else
          r.reply "Podatka o vremenu ni..."

  bot.command /^\.radar/i,
    ".radar Izpiše povezavo do radarske slike padavin"
    (r) ->
      r.reply "Radarska slika padavin: http://www.arso.gov.si/vreme/napovedi%20in%20podatki/radar_anim.gif"
