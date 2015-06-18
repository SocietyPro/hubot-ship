{Robot,Adapter,TextMessage,User} = require 'hubot'

vertx = require 'vertx-eventbus-client'
vertxServerAddress = process.env.VERTX_SERVER_ADDRESS

class Ship extends Adapter

  constructor: (robot) ->
    super
    @robot = robot
    @robot.logger.info "Constructor"

  send: (envelope, strings...) ->
    @robot.logger.info "Send"
    @robot.logger.info strings
    @robot.logger.info envelope
    for msg in strings
      hubotObj =
        type: 'hubot'
        message: msg
        id: true

      if envelope.message.channelId
        hubotObj.channelId = envelope.message.channelId
      else
        if envelope.message.receiverId
          hubotObj.receiverId = envelope.message.receiverId

      @eventbus.send 'webhook', JSON.stringify hubotObj

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"

  run: ->
    self = this
    @robot.logger.info "Run"
    return @robot.logger.error "No vertx address provide to hubot" unless vertxServerAddress
    @eventbus = new vertx.EventBus vertxServerAddress
    @eventbus.onopen = ->
      self.emit "connected"
      self.robot.logger.info "Connected to event bus"
      self.eventbus.registerHandler 'message', (msg) ->
        message = JSON.parse msg
        user = new User message.authorId, name: 'Ship User'
        messageToHubot = new TextMessage user, message.text, message._id, message
        messageToHubot.channelId = message.channelId
        messageToHubot.receiverId = message.receiverId
        self.robot.logger.info message
        self.robot.receive messageToHubot

exports.use = (robot) ->
  new Ship robot