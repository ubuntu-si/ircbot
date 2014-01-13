module.exports = (bot) ->
  
  bot.regexp /^.apt (.+)/,
    ".apt <paket> -- Najde pakete po imenu na packages.ubuntu.com",
    (match, r) ->

      apt = (paket, cb)=>
        url = "http://packages.ubuntu.com/search?suite=all&searchon=names&keywords=#{encodeURI(paket)}"
        bot.fetchHTML url , ($)->
          if $?
              paketi = []
              for paket in $("#psearchres h3")
                arches = []
                for arch in $(paket).next().find("li .resultlink")
                  archname = $(arch).text().trim()
                  if archname.indexOf("-") == -1
                    arches.push archname
                paketi.push "#{$(paket).text().replace("Package ","")} {#{arches.join(", ")}}"
              cb paketi.reverse().slice(-10).join "\n"
          else
              cb "Ne najdem"

      apt match[1].trim(), (answer)->
        r.reply answer

  bot.regexp /^.aptf (.+)/,
    ".aptf <ime_datoteke> -- Najde pakete po vsebini na packages.ubuntu.com",
    (match, r) ->
      aptf = (paket, cb)=>
        url = "http://packages.ubuntu.com/search?searchon=contents&keywords=#{encodeURI(paket)}&mode=exactfilename&suite=saucy&arch=any"
        bot.fetchHTML url , ($)->
          if $?
              paketi = []
              for paket in $("td.file") 
                paketi.push [$(paket).text().trim(), $(paket).next().text().trim()].join(" > ")
              cb paketi.reverse().slice(-10).join "\n"
          else
            cb "Ne najdem"

      aptf match[1].trim(), (answer)->
        r.reply answer