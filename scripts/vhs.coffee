# Description:
#   Twitter stuff for VHS Hubot
#
# Dependencies:
#   "<module name>": "<module version>"
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#   HUBOT_TWITTER_ACCESS_TOKEN
#   HUBOT_TWITTER_ACCESS_TOKEN_SECRET
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
  consumer_key = process.env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret = process.env.HUBOT_TWITTER_CONSUMER_SECRET
  access_token = process.env.HUBOT_TWITTER_ACCESS_TOKEN
  access_secret = process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET
  T = new Twit({
    consumer_key:         consumer_key,
    consumer_secret:      consumer_secret,
    access_token:         access_token,
    access_token_secret:  access_secret
  })

  vhs_account_twitter_id = 24754042
  ignoreUsers = []
  robot.brain.on 'loaded', =>
    ignoreUsers = robot.brain.get('vhs-ignore-twitter-users') or []

  mention = T.stream('user', { with: 'user', track: '@VHS' })
  mention.on 'tweet', (msg) =>
    name = msg.user.screen_name
    rt_name = ''
    if 'retweeted_status' of msg
      rt_name = msg.retweeted_status.user.screen_name

    ignoredUser = name in ignoreUsers
    ignoredUserRetweet = rt_name in ignoreUsers
    if ignoredUser or ignoredUserRetweet
      return

    text = 'got tweet from ' + name + ': ' + msg.text
    robot.messageRoom '#vhs-pr', text

    # # more complicated way:
    # ignored_retweets = robot.brain.get('vhs-ignore-retweets') or []
    # if 'retweeted_status' of msg
    #   console.log 'this is a retweet!'
    #   if msg.retweet_status.id in ignored_retweets
    #     console.log "it's in the ignore list, returning"
    #     return
    #   recent_retweets = robot.brain.get('vhs-recent-retweets') or []
    #   retweet =
    #     id: msg.retweet_status.id
    #     text: msg.retweet_status.text
    #   if recent_retweets.length >= 5
    #     recent_retweets.shift()
    #   recent_retweets.push retweet
    #   robot.brain.set 'vhs-recent-rewteets', recent_retweets

  from_vhs = T.stream('statuses/filter', { follow: vhs_account_twitter_id })
  from_vhs.on 'tweet', (msg) =>
    if msg.user.id == vhs_account_twitter_id
      return
    text = 'got tweet from ' + msg.user.screen_name + ': ' + msg.text
    robot.messageRoom '#vhs-pr', text


  robot.respond /block twitter user (.*)/, (res) =>
    name = res.match[1]
    if not ignoreUsers.include? name
      res.reply "Alrighty, I'll ignore @"+name+" from now on"
      ignoreUsers.push name
      robot.brain.set 'vhs-ignore-twitter-users', ignoreUsers
    else
      res.reply "I'm already blocking that user!"

  robot.respond /unblock twitter user (.*)/, (res) =>
    name = res.match[1]
    if ignoreUsers.include? name
      res.reply "Alrighty, I'll stop ignoring @"+res.match[1]+" from now on"
      index = ignoreUsers.indexOf name
      ignoreUsers.splice index, 1
      robot.brain.set 'vhs-ignore-twitter-users', ignoreUsers
    else
      res.reply "I'm not ignoring anybody on Twitter named @"+name+"!"

  robot.respond /what twitter users are you blocking/, (res) =>
    res.reply "These are the Twitter users I'm ignoring right now: " + ignoreUsers.join ','
