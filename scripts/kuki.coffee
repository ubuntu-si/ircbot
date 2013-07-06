moment = require 'moment'
moment.lang("sl")
spawn = require("child_process").spawn

module.exports = (bot) ->

  bot.regexp /^\.kuki (.*)$/,
    ".kuki <url> -- Preveri kako sledi stran uporabniku, uporabno pri ZEKom-1",
    (match, r) ->
      url_r = /(http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?/
      url = r.text.replace(".kuki ", "")

      unless url_r.test url
        r.privmsg "#{url} je neveljaven"
        bot.say "<#{r.nick}> #{url}", "dz0ny"
      else
        bot.say "<#{r.nick}> #{url}", "dz0ny"
        arg = "--proxy=localhost:8123 --ignore-ssl-errors=true /opt/teststrani.coffee #{url}"
        spwa = spawn("phantomjs", arg.split(" "))
        spwa.stdout.setEncoding('utf8')
        spwa.stdout.on "data", (data) =>
          r.privmsg data

        spwa.stderr.setEncoding('utf8')
        spwa.stderr.on "data", (data) =>
          r.privmsg data
        