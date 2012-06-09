
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

{log,error,inspect} = require 'util'
BinaryTree = require 'btree'
_ = require 'underscore'
moment = require 'moment'

contains = (item, text) -> (text.indexOf(item) isnt -1)

class InMemory
  constructor: () ->
    @events = []

  push: (event) ->
    # for the moment, we can only manage insertion at the end
    # TODO later: use https://github.com/vadimg/js_bintrees
    first = _.first @events
    first.previous = event
    event.last = first

    last = _.last @events
    last.next = event
    event.previous = last

    @events.push event


class PlaybackModule

  constructor: (main) ->
    @cursor = 0
    @running = false
    @rate = 1.0

    fire = (event) =>
      BROKEN
      next = main.database.nextr event.timestamp
      delta = event.timestamp - next.timestamp
      setTimeout delta, -> 
        @fire nextEvent

    # give playback capabilities to the main class
    main.play = (rate=1.0) => 
      @rate = rate
      first = main.database.first
      if first
        log "firing first event"
        fire first
      else
        log "no event to fire"

class RecordModule

  constructor: (main) ->

    # give record capabilities to the main class
    main.record = (data) -> 
      main.database.push         
        timestamp: moment()
        data: data

    main.recordAt = (timestamp, data) -> 
      throw "Not Implemented"
      return

class module.exports
  constructor: (url="") ->
    @database = new InMemory()

    # in case user want to use another backend
    if contains "file://", url
      @database = new SimpleFile url
    else
      log "using default database (in-memory)"

    # now initialize the sub-controllers
    new RecordModule @
    new PlaybackModule @
    
