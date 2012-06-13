
class InRedis
  constructor: () ->

    @prefix = "sampler::"

    @config = 
      port: 6379
      host: '127.0.0.1'
      # auth: 'password'

    redis = require "redis"
    @redis = redis.createClient @config.port, @config.host
    if @config.auth?
      @redis.auth @config.auth, ->
        @connected()
    else
      @connected()

    # if you'd like to select database 3, instead of 0 (default), call
    # client.select(3, function() { /* ... */ });

  connected: =>
    @redis.on "error", (err) => error err

    #@redis.on "subscribe", (channel, count) =>
    #  log "redis ready"

    #@redis.on "message", (channel, message) =>
    #  @emit channel: channel, message: message
      
    #for channel in @config.channels
    #  @redis.subscribe channel
    
    saveEventAt: (at, event) ->
      @redis.HMSET "#{@prefix}#{at}",
        data: "#{JSON.stringify event.data}"
        timestamp: "#{event.timestamp}"
        previous: "#{@prefix}#{event.previous.timestamp}"
        next: "#{@prefix}#{event.next.timestamp}"
 
     saveRawAt: (at, event) ->
      @redis.HMSET "#{@prefix}#{at}",
        data: "#{JSON.stringify event.data}"
        timestamp: "#{event.timestamp}"
        previous: "#{@prefix}#{event.previous}"
        next: "#{@prefix}#{event.next}"
 
    getLimits: (onComplete) ->
      @redis.HMGET "#{@prefix}limits", (err, value) ->
        if err
          onComplete no
          return
        onComplete
          first: moment(value.first)
          last: moment(value.last)

    setLimits: (first, last, onComplete) ->
      @redis.HMSET "#{@prefix}limits", 
        first: "#{first}"
        last: "#{last}"

    loadEvent: (at, onComplete) =>
      @redis.HGETALL "#{@prefix}#{at}", (err, res) ->
        if err 
          onComplete(no)
          return 
        onComplete 
          previous: moment res.previous
          next: res.next
          timestamp: moment res.timestamp
          data: JSON.parse res.data

    next: (event, onComplete) =>

    push: (event) =>