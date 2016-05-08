parser = require 'parse-rss'

#module.exports = (bot) ->

url = "https://wordpress.org/news/category/releases/feed/"
interval = 60000
# interval is in ms so 72000000 is 2 hrs
do timeout = ->
  today = new Date
  parser url, (err,rss)->
    console.log err if err
    pubDate = new Date(rss[0].pubDate)
    if pubDate.getMonth() == today.getMonth() && pubDate.getDate() == today.getDate()
      if 'Security' in rss[0].categories
        console.log "URGENT! #{rss[0].title} - #{rss[0].link}\nPublished: #{rss[0].date}"
      else
        console.log "Sweet #{rss[0].categories[1]} available! #{rss[0].title} - #{rss[0].link}\nPublished: #{rss[0].date}"
    else
      console.log "#{pubDate}  !not equal! #{today}"

setTimeout timeout, interval
