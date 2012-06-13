
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

# third party modules
_ = require 'underscore'
moment = require 'moment'

# project modules
{delay,contains} = require './misc/toolbox'

class module.exports

  constructor: (options) ->
  
    # TODO do something more clean and safe here
    # eg. check parameters..
    @store = options.record.store
    @rate = options.rate
    @looped = options.looped

    @onError = options.on.error
    @onData = options.on.data
    @onEnd = options.on.end

    @enabled = yes
    @paused = no
    @next = no

    @latency = 0 # incremented when we lose time..

  pause: () =>
    @paused = yes
    @latency = 0 # do not count latency when paused

  resume: () => 
    unless @enabled
      @onEnd()
      @onError "cannot resume: we are not enabled"
      return

    @paused = no

    # du we already have a running cursor or not?
    @next = @store.first unless @next

    @fire()

  fire: =>
    unless @enabled
      @onEnd()
      @onError "cannot fire: we are not enabled"
      return

    if @paused
      log "cannot fire: paused"
      return

    evt = @next

    unless evt
      @onEnd()
      @onError "cannot fire: next is empty()"
      return

    # when did we fire?
    fired = moment()

    # emit the event to our Player
    @onData timestamp: evt.timestamp, data: evt.data 

    @store.next evt, (next) =>

      # did we hit the loop cue point?
      if next is @store.first
        @onEnd()
        unless @looped
          @enabled = no
          @onEnd()
          return

      # theorical delay until next event (with threshold applied)
      theoricDelay = (next.timestamp - evt.timestamp) / @rate

      # let's compute how much time we lost with database/network queries
      dbLatency = moment() - fired - Math.abs(latency)

      # we will compensate system latency by shorting time to next event
      realDelay = theoricDelay - dbLatency
      if realDelay < 0
        @latency = realDelay
        realDelay = 0 

      # prepare the event to be fire next time
      @next = next
      # let's try to fire it
      delay realDelay, =>
        @fire()
