# Description:
#   Responds with snarky gif. Blame jarrett
#
# Commands:
#   vhsbot open vhs - responds with snarky gif
#
# Notes:
#   Lookit all this coffeescript!
#
# Author:
#   seanhagen
#

module.exports = (robot) ->
  gif_url = "http://i.imgur.com/TTPPenF.gif"

  robot.respond /open vhs/, (res) =>
    res.reply gif_url
