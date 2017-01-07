# Description:
#   Forum discussion alerts

moment = require 'moment'

last_check_time = new Date()

check_forum = (bot) ->
  bot.fetchJSON "https://www.ubuntu.si/forum/discussions.json", (data) ->
    if data
      for i, topic of data['Discussions']
        if moment(topic['DateLastComment']) > last_check_time
          result = "[forum] @#{topic['LastName']} #{topic['Name']} > https://www.ubuntu.si/forum/discussion/#{topic['DiscussionID']}"
          bot.say result, "#ubuntu-si"
      last_check_time =  new Date()

module.exports = (bot) ->
  bot.say "Čas je #{last_check_time}", "#ubuntu-si"
  setInterval((-> check_forum(bot)), 60*1000)

module.exports.check_forum = check_forum