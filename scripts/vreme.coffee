crypto = require 'crypto'

module.exports = (bot) ->

  oddaljenost = (lat1, lon1, lat2, lon2) ->
    ## http://mathworld.wolfram.com/SphericalTrigonometry.html
    R = 6371; #v KM
    return Math.acos(Math.sin(lat1)*Math.sin(lat2) + 
                      Math.cos(lat1)*Math.cos(lat2) *
                      Math.cos(lon2-lon1)) * R

  yql = (yqlq, cbl) ->
   
    uri = "http://query.yahooapis.com/v1/public/yql?format=json&q=" + encodeURIComponent(yqlq)
    bot.fetchJSON uri, (body) ->
      cbl body.query.results


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

    bot.fetchJSON "http://api.openweathermap.org/data/2.5/weather?APPID=017203dd3aeecf20cfb0b4bc1b032b36&lat=#{lat}&lon=#{lon}", (res) ->
      if res
        vzhod = moment.unix(res.sys.sunrise).format("HH:mm:ss")
        zahod = moment.unix(res.sys.sunset).format("HH:mm:ss")
        t = (res.main.temp-273.15).toFixed(2)
        cb "#{res.name}: #{t}°C, Sončni vzhod: #{vzhod}, Sončni zahod: #{zahod}"
      else
        cb "Podatkov o vremenu ni mogoče pridobiti..."


  arso = (key, cb) ->
    bot.fetchJSON "http://maps.googleapis.com/maps/api/geocode/json?address=#{encodeURI(key)},%20slovenija&sensor=true", (res) ->
      unless res # ne jnajde kraja
        vreme key, (msg)->
          cb "#{key}: #{msg}"
      else #najde kraj
        try
          krajg = _.first(_.first(res.results).address_components).short_name
          loc = _.first(res.results).geometry.location
          imeg = _.first(res.results).formatted_address
          if (/Slovenia/i).test imeg 
            yql 'select metData.ddavg_longText, metData.rh, metData.ffavg_val, metData.domain_altitude, metData.t, metData.tsValid_issued, metData.domain_longTitle, metData.domain_lat, metData.domain_lon from xml where url in (select title from atom where url="http://spreadsheets.google.com/feeds/list/0AvY_vCMQloRXdE5HajQxUGF5ZEZYUjhKNG9EeVl2bFE/od6/public/basic")',
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
                  
                vreme2 loc.lat, loc.lng, (msg)->
                  cb """ARSO: #{kraj.metData.domain_longTitle} (#{kraj.metData.domain_altitude}m): #{kraj.metData.t}°C @#{kraj.metData.tsValid_issued}.\nVlažnost: #{kraj.metData.rh}% #{veter}\nhttp://forecast.io/#/f/#{loc.lat},#{loc.lng}\n""" + msg
          else
            vreme key, (msg)->
              cb "#{imeg}: #{msg}"   
        catch e
          console.log  e
          cb "Neznana lokacija"

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
          console.log vsebina
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
          console.log vsebina
          r.reply vsebina
        else
          r.reply "Podatka o vremenu ni..."

