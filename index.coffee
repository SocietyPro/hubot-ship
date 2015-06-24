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
    for msg in strings
      hubotObj =
        type: 'hubot'
        message: msg
        id: true

      webhook =
        name: @robot.name

      hubotObj.webhook = webhook

      if envelope.room
        hubotObj.channelId = envelope.room

      if not hubotObj.channelId and not hubotObj.receiverId
        if envelope.message.channelId
          hubotObj.channelId = envelope.message.channelId
        else
          if envelope.message.receiverId
            hubotObj = envelope.message.receiverId
          else
            @robot.logger.info "No Channel specified in response"
            continue

      @eventbus.send 'webhook', JSON.stringify hubotObj

  reply: (envelope, strings...) ->
    @robot.logger.info "Reply"
    for msg in strings
      hubotObj =
        type: 'hubot'
        message: msg
        id: true

      webhook =
        name: @robot.name

      hubotObj.webhook = webhook

      if envelope.room
        hubotObj.channelId = envelope.room

      if not hubotObj.channelId and not hubotObj.receiverId
        if envelope.message.channelId
          hubotObj.channelId = envelope.message.channelId
        else
          if envelope.message.receiverId
            hubotObj = envelope.message.receiverId
          else
            @robot.logger.info "No Channel specified in response"

      @eventbus.send 'webhook', JSON.stringify hubotObj

  run: ->
    self = this
    return @robot.logger.error "No vertx address provide to hubot" unless vertxServerAddress
    @eventbus = new vertx.EventBus vertxServerAddress
    @eventbus.onopen = ->
      self.emit "connected"
      self.robot.logger.info "Connected to event bus"
      self.eventbus.registerHandler 'message', (msg) ->
        message = JSON.parse msg
        user = new User message.authorId, name: message.authorName
        user.room = message.channelId
        messageToHubot = new TextMessage user, message.text, message._id, message
        messageToHubot.channelId = message.channelId
        messageToHubot.receiverId = message.receiverId
        self.robot.receive messageToHubot

exports.use = (robot) ->
  new Ship robot