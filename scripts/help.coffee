# Description:
#   Makes vhsbot a bit more helpful
#
# Commands:
#   hubot help - Output a nice help message
#   hubot list commands - Displays all of the help commands that Hubot knows about.
#   hubot list commands <query> - Displays all help commands that match <query>.
#
# Notes:
#   Pulled the 'list commands' from the hubot-help
#
# Author:
#   seanhagen
#

module.exports = (robot) ->

  robot.respond /help/, (res) ->
    res.send "Hey, I'm the VHS chat bot ( aka "+res.robot.name+" )"
    res.send "If you want to get a list of commands, pm me 'list commands' ( you can look for specific commands by using 'list commands <words>')"
    res.send "If you want to get a look at my code, head over to http://github.com/vhs/vhsbot"

  robot.respond /list commands(?:\s+(.*))?$/i, (msg) ->
    cmds = renamedHelpCommands(robot)
    filter = msg.match[1]

    if filter
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(filter, 'i')
      if cmds.length == 0
        msg.send "No available commands match #{filter}"
        return

    emit = cmds.join "\n"

    msg.send emit

renamedHelpCommands = (robot) ->
  robot_name = robot.alias or robot.name
  help_commands = robot.helpCommands().map (command) ->
    command.replace /hubot/ig, robot_name
  help_commands.sort()
