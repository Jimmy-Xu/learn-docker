# Description:
#   check class schedule, then notify via message via email and growl
#
# Dependencies:
#   node-growl
#
# Configuration:
#   HUBOT_EXT_CMD_BIN
#   HUBOT_EXT_CMD_ARG
#   HUBOT_EXT_CMD_OPT
#   HUBOT_CHECK_INTERVAL
#   HUBOT_QUIET_START_HOUR
#   HUBOT_QUIET_END_HOUR
#   HUBOT_GNTP_SERVER
#   HUBOT_GNTP_PASSWORD
#   HUBOT_EMAIL_USERNAME   - The username of the email accoun that hubot will use to send email notification
#   HUBOT_EMAIL_PASSWORD   - The password for the email account
#   HUBOT_EMAIL_TO         - Email address to receive message(xxx@139.com)
#   HUBOT_EMAIL_CC         - Email address to receive message(yyy@139.com)
#
# Commands:
# hubot show env        # check show env
# hubot check schedule  # check schedule immediately
#
# Author:
#   Jimmy Xu <xjimmyshcn@gmail.com>
#

nodeGrowl = require 'node-growl'
nodeMailer = require 'nodemailer'

module.exports = (robot) ->

#==============================
# variable
#==============================
  gntpOpts =
    server: process.env.HUBOT_GNTP_SERVER
    password: process.env.HUBOT_GNTP_PASSWORD
    appname: "schedule-monitor"
  cmdOpts =
    bin: process.env.HUBOT_EXT_CMD_BIN
    arg: "#{process.env.HUBOT_EXT_CMD_ARG} #{process.env.HUBOT_EXT_CMD_OPT}"
  mailOpts =
    host: 'smtp.sina.com'
    secureConnection: true
    to: if process.env.HUBOT_EMAIL_TO then process.env.HUBOT_EMAIL_TO else ""
    cc: if process.env.HUBOT_EMAIL_CC then process.env.HUBOT_EMAIL_CC else ""
    auth:
      user: process.env.HUBOT_EMAIL_USERNAME
      pass: process.env.HUBOT_EMAIL_PASSWORD
  checkOpts =
    interval: if process.env.HUBOT_CHECK_INTERVAL then parseInt process.env.HUBOT_CHECK_INTERVAL else 8
    quiet_start_hour: if process.env.HUBOT_QUIET_START_HOUR then parseInt process.env.HUBOT_QUIET_START_HOUR else 0
    quiet_end_hour: if process.env.HUBOT_QUIET_END_HOUR then parseInt process.env.HUBOT_QUIET_END_HOUR else 6
  scheduleResult =
    NotChanged: "课程无变化"
    Error: "程序错误"
    Changed: null
    QuietPeriod: "静默期"

  #==============================
  # function
  #==============================
  run_cmd = (cmd, args, cb) ->
    console.debug "[schedule-monitor] spawn:", cmd, args
    spawn = require("child_process").spawn
    child = spawn(cmd, args)
    result = []
    child.stdout.on "data", (buffer) -> result.push buffer.toString()
    child.stderr.on "data", (buffer) -> result.push buffer.toString()
    child.stdout.on "end", -> cb result

  setTimer = (_interval) ->
    if _interval is 0
      _waitTime = 0
      robot.logger.info "初次运行,立即检查课表"
      sendMail "开始监控课表", "检查间隔:#{checkOpts.interval}分钟, 随机范围:[-1,1]\n#{process.env.HUBOT_EXT_CMD_OPT}"
    else
      hour = (new Date().getUTCHours()+8) % 24
      #robot.logger.info "hour: #{hour} quiet_start_hour:#{checkOpts.quiet_start_hour} quiet_end_hour:#{checkOpts.quiet_end_hour}"
      if hour >= checkOpts.quiet_start_hour and hour < checkOpts.quiet_end_hour
        _waitTime = 30
      else
        # random number: [-1,1]
        _waitTime = Math.floor(Math.random() * 3) - 1
      robot.logger.info "check again after #{_interval + _waitTime} minutes"
    setTimeout doFetch, (_interval+_waitTime) * 60 * 1000, ((e, result) ->
      if e
        robot.logger.info "[doFetch] result: #{e}"
      else
        title = "课表变更通知"
        robot.logger.info "title: #{title} content: #{result}"
        # notify via email
        for content in result.split "\n\n"
          sendMail title, content
        # notify via gntp-send
        if gntpOpts.server
          nodeGrowl title, result, gntpOpts, (text) ->
            robot.logger.info "gntp result: #{text}"
        else
          robot.logger.info "[WARN] skip to send message to growl"
    ), (() ->
      setTimer checkOpts.interval
    )

  doFetch = (callback, onFinish) ->
    hour = (new Date().getUTCHours()+8) % 24
    #robot.logger.info "hour: #{hour} quiet_start_hour:#{checkOpts.quiet_start_hour} quiet_end_hour:#{checkOpts.quiet_end_hour}"
    if hour >= checkOpts.quiet_start_hour and hour <= checkOpts.quiet_end_hour
      robot.logger.info "当前时段: #{hour}"
      callback scheduleResult.QuietPeriod, ""
      if onFinish
        onFinish()
    else
      robot.logger.info "Check it!"
      run_cmd cmdOpts.bin, cmdOpts.arg.split(" "), (result) ->
        #robot.logger.info "[run_cmd] result: #{result}"
        result = result.join("")
        if not result
          callback scheduleResult.NotChanged, ""
        else
          callback scheduleResult.Changed, result
        if onFinish
          onFinish()

  sendMail = (subject, content) ->
    if mailOpts.auth.user and mailOpts.auth.pass and mailOpts.to
      options =
        from: "#{process.env.HUBOT_EMAIL_USERNAME}"
        to: "#{mailOpts.to}"
        cc: "#{mailOpts.cc}"
        subject: subject
        text: content
        html: "#{content.split("\n").join("<br/>")}"
        attachments: []
      mailTransport = nodeMailer.createTransport mailOpts
      mailTransport.sendMail options, (err, msg) ->
        if err
          robot.logger.info "[sendMail] Error: #{err}"
        else
          robot.logger.info "[sendMail] 已接收： #{msg.accepted}"
    else
      robot.logger.info "[WARN] skip send message via email"

  #==============================
  # main
  #==============================

  # start monitor task
  setTimer 0

  robot.respond /show env/i, (resp) ->
    console.log "\n[cmdOpts]:\n", cmdOpts
    console.log "[mailOpts]:\n", mailOpts
    console.log "[gntpOpts]:\n", gntpOpts

  robot.respond /check schedule/i, (resp) ->
    robot.logger.info "正在检查课表..."
    run_cmd cmdOpts.bin, cmdOpts.arg.split(" "), (result) ->
      robot.logger.info "result:#{result}"
      result = result.join("")
      if not result
        result = "课表无变更"
      resp.reply result
      # notify via gntp-send
      if gntpOpts.server
        nodeGrowl "check schedule", result, gntpOpts, (text) ->
          if text isnt null
            robot.logger.info ">[sender:#{resp.message.user.name}] gntp-send failed(#{text})"
          robot.logger.info ">gntp-send OK"
      else
        robot.logger.info "[WARN] skip to send message to growl"
