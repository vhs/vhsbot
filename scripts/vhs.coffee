# Description:
#   Twitter stuff for VHS Hubot
#
# Dependencies:
#   "<module name>": "<module version>"
#
# Configuration:
#   HUBOT_TWIT_CONSUMER_KEY
#   HUBOT_TWIT_CONSUMER_SECRET
#   HUBOT_TWIT_ACCESS_TOKEN
#   HUBOT_TWIT_ACCESS_SECRET
#
# Commands:
#   hubot block twitter user (name) - blocks that twitter user, their tweets won't show up
#   hubot unblock twitter user (name) - unblock that twitter user
#   hubot what twitter users are you blocking - list all the users currently being blocked
#
# Notes:
#   Lookit all this coffeescript!
#
# Author:
#   seanhagen
Twit = require 'twit'

Array::include = ((o) ->
  @indexOf(o) isnt -1
)

module.exports = (robot) ->
  consumer_key = process.env.HUBOT_TWIT_CONSUMER_KEY
  consumer_secret = process.env.HUBOT_TWIT_CONSUMER_SECRET
  access_token = process.env.HUBOT_TWIT_ACCESS_TOKEN
  access_secret = process.env.HUBOT_TWIT_ACCESS_SECRET
  T = new Twit({
    consumer_key:         consumer_key,
    consumer_secret:      consumer_secret,
    access_token:         access_token,
    access_token_secret:  access_secret
  })

  stream = T.stream('user', { with: 'user', track: '@VHS' })

  stream.on 'tweet', (msg) ->
    ignoreUsers = robot.brain.get('vhs-ignore-twitter-users') or []
    name = msg.user.screen_name
    if not ignoreUsers.include? name
      text = 'got tweet from ' + name + ': ' + msg.text
      robot.messageRoom '#vhs-pr', text
      console.log text

  robot.respond /block twitter user (.*)/, (res) ->
    ignoreUsers = robot.brain.get('vhs-ignore-twitter-users') or []
    name = res.match[1]
    if not ignoreUsers.include? name
      res.reply "Alrighty, I'll ignore @"+name+" from now on"
      ignoreUsers.push name
      robot.brain.set 'vhs-ignore-twitter-users', ignoreUsers
    else
      res.reply "I'm already blocking that user!"

  robot.respond /unblock twitter user (.*)/, (res) ->
    ignoreUsers = robot.brain.get('vhs-ignore-twitter-users') or []
    name = res.match[1]
    if ignoreUsers.include? name
      res.reply "Alrighty, I'll stop ignoring @"+res.match[1]+" from now on"
      index = ignoreUsers.indexOf name
      ignoreUsers.splice index, 1
      robot.brain.set 'vhs-ignore-twitter-users', ignoreUsers
    else
      res.reply "I'm not ignoring anybody on Twitter named @"+name+"!"

  robot.respond /what twitter users are you blocking/, (res) ->
    ignoreUsers = robot.brain.get('vhs-ignore-twitter-users') or []
    res.reply "These are the Twitter users I'm ignoring right now"
    for user in ignoreUsers
      res.reply "  "+user
