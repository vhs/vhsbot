# Description:
#   Get the free book of the day from Packtpub
#
# Dependencies:
#   "cheerio" : "~0.19.0"
#
# Commands:
#   hubot what's the free book today
#   hubot todays free book
#
# Notes:
#   Lookit all this coffeescript!
#
# Author:
#   seanhagen
#
cheerio = require 'cheerio'

free_book_url = "https://www.packtpub.com/packt/offers/free-learning"

module.exports = (robot) ->

  robot.respond /what.s the free book today/, (msg) ->
    get_free_book msg, robot

  robot.respond /todays free book/, (msg) ->
    get_free_book msg, robot


get_free_book = (msg, robot) =>
  countdown = robot.brain.get('packt-countdown') or null
  if countdown?
    countdown *= 1000

  if not countdown? or countdown < Date.now()
    robot.http(free_book_url)
      .get() (err, res, body) =>
        $ = cheerio.load body

        title = $('.dotd-title h2').text().trim()
        countdown = $('.packt-js-countdown').data('countdown-to')

        robot.brain.set 'packt-countdown', countdown
        robot.brain.set 'packt-title', title

        book_reply msg, title, countdown

  else
    title = robot.brain.get 'packt-title'
    countdown = robot.brain.get 'packt-countdown'
    book_reply msg, title, countdown

book_reply = (msg, title, countdown) ->
  now = Date.now()
  countdown *= 1000

  hourDiff = countdown - now
  diffHrs = Math.floor((hourDiff % 86400000) / 3600000);
  diffMins = Math.round(((hourDiff % 86400000) % 3600000) / 60000);

  msg.reply "Packt free book of the day: " + title
  msg.reply "There is " + diffHrs + " hours and " + diffMins + " minutes left to claim this book!"
