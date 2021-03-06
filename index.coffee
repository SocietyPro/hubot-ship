{Robot,Adapter,TextMessage,User} = require 'hubot'

vertx = require 'vertx-eventbus-client'
vertxServerAddress = process.env.VERTX_SERVER_ADDRESS

class Ship extends Adapter

  constructor: (robot) ->
    super
    @robot = robot
    @robot.logger.info "Constructor"

  send: (envelope, strings...) ->
    self = this
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
      else
        if envelope.message.channelId
          hubotObj.channelId = envelope.message.channelId
        else
          if envelope.message.receiverId == 'hubot'
            hubotObj.receiverId = envelope.user.id
          else
            @robot.logger.info "No Channel specified in response"
            continue

      ebObj =
        requesterId: 'hubot'
        #requesterOrigin: 'hubot'
        #requesterWebhook: webhook
        channelId: hubotObj.channelId
        receiverId: hubotObj.receiverId
        text: msg

      #@eventbus.send 'webhook', JSON.stringify hubotObj
      @eventbus.send 'message.post', ebObj, (reply) ->
        if !reply.ok
          self.robot.logger.error 'message.post failed:', reply

  reply: (envelope, strings...) ->
    self = this
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
      else
        if envelope.message.channelId
          hubotObj.channelId = envelope.message.channelId
        else
          if envelope.message.receiverId == 'hubot'
            hubotObj.receiverId = envelope.user.id
          else
            @robot.logger.info "No Channel specified in response"
            continue

      ebObj =
        requesterId: 'hubot'
        #requesterOrigin: 'hubot'
        #requesterWebhook: webhook
        channelId: hubotObj.channelId
        receiverId: hubotObj.receiverId
        text: msg

      #@eventbus.send 'webhook', JSON.stringify hubotObj
      @eventbus.send 'message.post', ebObj, (reply) ->
        if !reply.ok
          self.robot.logger.error 'message.post failed:', reply

  run: ->
    self = this
    return @robot.logger.error "No vertx address provide to hubot" unless vertxServerAddress
    @eventbus = new vertx.EventBus vertxServerAddress
    @eventbus.onopen = ->
      self.emit "connected"
      self.robot.logger.info "Connected to event bus"
      re = new RegExp('^'+self.robot.name+' ', 'i')
      self.eventbus.registerHandler 'message.wasPosted', (msg) ->
        message = msg.message
        if message.authorId == 'hubot'
          return
        if !message.channelId and message.receiverId == 'hubot'
          if !re.test(message.text)
            message.text = self.robot.name + ' ' + message.text

        user = new User message.authorId, name: message.authorName
        user.room = message.channelId
        messageToHubot = new TextMessage user, message.text, message._id, message
        messageToHubot.channelId = message.channelId
        messageToHubot.receiverId = message.receiverId
        self.robot.receive messageToHubot

exports.use = (robot) ->
  new Ship robot