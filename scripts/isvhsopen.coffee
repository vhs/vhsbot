# Description:
#   Let people check if VHS is open via VHSBOT!
#
# Dependencies:
#   "timeago-words": "0.0.3"
#
# Commands:
#   is vhs open - tells users if vhs is open or not
#   vhs is open - tells users if vhs is open or not
#
# Notes:
#   Lookit all this coffeescript!
#
# Author:
#   seanhagen
#
timeago = require 'time_ago_in_words'

module.exports = (robot) ->
  api_url = "http://api.hackspace.ca/s/vhs/data/door.json"

  is_vhs_open = (res) =>
    robot.http(api_url)
      .header('Accept','application/json')
      .get() (err, response, body) =>
        if err
          res.send "Unable to check the VHS API =( #{err}"
          return

        data = JSON.parse body
        msg = "VHS isn't open right now =("
        if data.value == "open"
          msg = "VHS is open, last updated " + timeago(data.last_updated * 1000)

        res.reply msg

  robot.hear /is vhs open/, is_vhs_open
  robot.hear /vhs is open/, is_vhs_open
