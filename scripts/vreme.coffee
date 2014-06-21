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
    # #glavna td.vsebina > table > tbody > tr
    bot.fetchHTML "http://www.arso.gov.si/potresi/obvestila%20o%20potresih/aip/", ($)->
      apotresi = []
      for e in $("#glavna td.vsebina table tr")
        e = cheerio(e)
        magnituda = Number(e.find("td:nth-child(4)").text())
        if magnituda > 0
          apotresi.push {
            date: e.find("td:nth-child(1)").text().trim(),
            lat: e.find("td:nth-child(2)").text().trim(),
            lon: e.find("td:nth-child(3)").text().trim(),
            m: magnituda,
            loc: e.find("td:nth-child(6)").text().trim(),
          }
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
            yql 'select metData.ddavg_longText, metData.rh, metData.ffavg_val, metData.domain_altitude, metData.t, metData.tsValid_issued, metData.domain_longTitle, metData.domain_lat, metData.domain_lon, metData.nn_shortText, metData.wwsyn_longText from xml where url in (select title from atom where url="http://spreadsheets.google.com/feeds/list/0AvY_vCMQloRXdE5HajQxUGF5ZEZYUjhKNG9EeVl2bFE/od6/public/basic")',

              # seznam = document.querySelectorAll("td a")
              #   for(i=0; i< seznam.length;i++){
              #     if(seznam[i].href.indexOf(".xml") != -1){
              #       console.log(seznam[i].href)
              #     }
              #   }
              (lokacije)->
                lokacije = lokacije.data
                lokacije.sort (a, b)->
                  a = oddaljenost a.metData.domain_lat, a.metData.domain_lon, loc.lat, loc.lng
                  b = oddaljenost b.metData.domain_lat, b.metData.domain_lon, loc.lat, loc.lng
                  return a - b;
                kraj = _.first(lokacije)

                if kraj.metData.ddavg_longText?
                  if kraj.metData.ffavg_val?
                    veter = "Veter: #{kraj.metData.ddavg_longText} #{kraj.metData.ffavg_val} m/s"
                  else
                    veter = "Veter: #{kraj.metData.ddavg_longText}"
                else
                  veter = ""

                if kraj.metData.nn_shortText?
                  oblacnost = kraj.metData.nn_shortText
                else
                  oblacnost = ""

                if kraj.metData.wwsyn_longText?
                  vremenski_pojav = kraj.metData.wwsyn_longText
                else
                  vremenski_pojav = ""
                vreme2 loc.lat, loc.lng, (msg)->
                  cb """ARSO: #{kraj.metData.domain_longTitle} (#{kraj.metData.domain_altitude}m): #{kraj.metData.t}°C @#{kraj.metData.tsValid_issued}.\nVlažnost: #{kraj.metData.rh}% #{veter} #{oblacnost} #{vremenski_pojav}\n""" + msg
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

  bot.command /^\.prognoza/i,
    ".prognoza Vremenska prognoza"
    (r) ->
      url = "http://www.arso.gov.si/vreme/napovedi%20in%20podatki/napoved.html"
      bot.fetchHTML url, ($)->
        if $?
          vsebina = $("td.vsebina p").eq(2).text()
          r.reply vsebina
        else
          r.reply "Podatka o vremenu ni..."


  bot.command /^\.napoved/i,
    ".napoved Vremenska napoved"
    (r) ->
      url = "http://www.arso.gov.si/vreme/napovedi%20in%20podatki/napoved.html"
      bot.fetchHTML url, ($)->
        if $?
          vsebina = $("td.vsebina p").eq(4).text()
          r.reply vsebina
        else
          r.reply "Podatka o vremenu ni..."
