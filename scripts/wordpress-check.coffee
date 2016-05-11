parser = require 'parse-rss'
colors = require('irc-colors')
#uncomment at merge
module.exports = (bot) ->

  url = "https://wordpress.org/news/category/releases/feed/"
  interval = 60000
  # interval is in ms so 1000 * 60 * 60  is 1 hr
  do wpCheck = ->
    today = new Date
    parser url, (err,rss)->
      console.log err if err
      pubDate = new Date(rss[0].pubDate)

      if pubDate.getMonth() == today.getMonth() && pubDate.getDate() == today.getDate() && pubDate.getHours() == today.getHours()
        if 'Security' in rss[0].categories
          bot.say "#{colors.bold.red('URGENT!')} #{rss[0].title} - #{rss[0].link}\nPublished: #{rss[0].date}", "#ubuntu-si"
        else
          bot.say "Sweet #{rss[0].categories.join(" ")} available! #{rss[0].title} - #{rss[0].link}\nPublished: #{rss[0].date}", "#ubuntu-si"

  setTimeout wpCheck, interval
