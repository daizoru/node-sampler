
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
events = require 'events'

# third party modules
moment             = require 'moment'

# project modules
{delay,contains}   = require './misc/toolbox'

class module.exports extends events.EventEmitter

  constructor: (options) ->
  
    # TODO do something more clean and safe here
    # eg. check parameters..
    @store = options.record.store
    @speed = options.speed
    @looped = options.looped


    @enabled = yes
    @paused = no
    @next = no

    @latency = 0 # incremented when we lose time..

    # buffer
    @buffer = []
    @bufferMax = 3

  pause: () =>
    @paused = yes
    @latency = 0 # do not count latency when paused

  resume: () => 
    #log "CURSOR#RESUME() CALLED"
    unless @enabled
      #@onEnd()
      @emit 'error', "cannot resume: we are not enabled"
      return

    #if @paused
    #  log "CURSOR#RESUME() paused -> cannot resume"
    @paused = no

    # du we already have a running cursor or not?
    @next = @store.first unless @next
    @emit 'begin'
    @fire()

  checkBuffer: =>
    if @buffer.length < @bufferMax
      # we need to fill it
      log "we have some room to bufferize"


  fire: =>
    #log "fire: next is #{inspect @next}"
    unless @enabled
      #@onEnd()
      @emit 'error', "cannot fire: we are not enabled"
      return

    if @paused
      log "cannot fire: paused"
      return

    evt = @next

    @emit 'data', timestamp: evt.timestamp, data: evt.data 
    fired = moment()
    @store.next evt, (next) =>

      unless next
        log "error, no more next in the DB.."
        @emit 'error', "store.next gave us nothing"
        return

      # did we hit the loop cue point?
      if next is @store.first
        unless @looped
          @enabled = no
          @emit 'end'
          return

      # theorical delay until next event (with threshold applied)
      theoricDelay = (next.timestamp - evt.timestamp) / @speed

      # let's compute how much time we lost with database/network queries
      dbLatency = (moment() - fired) + @latency

      # we will compensate system latency by shorting time to next event
      realDelay = theoricDelay - dbLatency
      if realDelay < 0
        @latency = realDelay
        realDelay = 0 
      else
        @latency = 0

      # prepare the event to be fire next time
      @next = next
      # let's try to fire it
      delay realDelay, =>
        @fire()
