
# Copyright (c) 2011, Julian Bilcke <julian.bilcke@daizoru.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of Julian Bilcke, Daizoru nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL JULIAN BILCKE OR DAIZORU BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# standard modules
{log,error,inspect} = require 'util'
{Stream} = require 'stream'

# third party modules
_ = require 'underscore'
moment = require 'moment'

# project modules
{delay,contains} = require './misc/toolbox'
{Record} = require './record'

class Read

  constructor: (main) ->
    @rate = 1.0
    @looped = no
    late = 0

    main.output = (cb) ->
      main.on 'event', cb

    fire = (event, onComplete=no) =>
      fired = moment()
      main.emit 'event', timestamp: event.timestamp, data: event.data 
      main.store.next event, (next) =>

        # did we hit the loop cue point?
        if next is main.store.first
          main.emit 'end', looping: @looped
          if onComplete
            onComplete looping: @looped
          return unless @looped

        # theorical delay until next event (with threshold applied)
        theoricDelay = (next.timestamp - event.timestamp) / @rate

        # let's compute how much time we lost with database/network queries
        dbLatency = moment() - fired - Math.abs(late)

        # we will compensate system latency by shorting time to next event
        realDelay = theoricDelay - dbLatency
        if realDelay < 0
          late = realDelay
          realDelay = 0 
        delay realDelay, -> fire next, onComplete

    # give playback capabilities to the main class
    main.startStream = (cb=no) => 
      onComplete = no

      if rate
        if cb
          @rate = rate
          onComplete = cb
        else
          if _.isNumber rate
            @rate = rate
          else
            onComplete = rate
       
      #log "PlaybackModule: playing at rate #{@rate}"
      first = main.store.first
      if first
        #log "firing first event"
        fire first, onComplete
      else
        #log "no event to fire"
        1

class Write

  constructor: (main) ->

    @inputs = []

    # give record capabilities to the main class
    main.write = (data) -> 
      #log "RecordModule: pushing into database the event"
      timestamp = moment()
      # do an INSERT (or PUT) in the database
      main.store.insert         
        timestamp: timestamp
        data: data
      #log "RecordModule: db is #{inspect main.database.events}"

      # update the duration cache
      main.duration = main.store.duration()
      timestamp

    main.listen = (stream, params) =>
      unless stream
        throw "error, no source specified"
        return
      msg = if params.msg? then params.msg else 'data'

      filter = if params.filter? then params.filter else (d) -> d
      input = stream.on msg, (data) -> main.write filter(data)
      @inputs.push input
      #log "started listening to #{msg}"

    main.close = ->
      
    main.overwrite = (timestamp, data) -> 
      throw "Not Implemented"
      return

class Record extends Stream
  constructor: (url) ->
    super()
    duration = 0
    @store = new MemoryStore()
    if contains "file://", url
      @store = new SimpleFile url
    new Write @
    new Read @

