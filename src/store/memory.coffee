
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
events = require 'events'

# third party modules
moment = require 'moment'

# project modules
toolbox = require '../misc/toolbox'
{delay,contains} = require '../misc/toolbox'
BinaryTree = require '../misc/btree'

# TODO emit errors when there are.. errors
class module.exports extends events.EventEmitter
  constructor: (@config) ->
    @events = []
    @first = no
    @last = no
    @_length = 0
    @flushing =
      version: 1

  write: (timestamp, data) =>

    event =
      timestamp: timestamp
      data: data
      
    # for the moment, we can only manage insertion at the end
    # TODO later: use https://github.com/vadimg/js_bintrees
    @first = if @events[0] then @events[0] else event
    @first.previous = event # connect the event to the beginning of loop
    event.next = @first

    @last = @events[@events.length - 1]
    @last = event unless @last
    @last.next = event
    event.previous = @last

    if @first and @last
      #log "got first and last: #{@last.timestamp - @first.timestamp}"
      @_length = @last.timestamp - @first.timestamp
    @_writeEvent event

  _writeEvent: (event) =>
    #log "store.Memory: _writeEvent: writing!"
    @events.push event
    @emit 'flushed', @flushing.version++
    yes

  # Get the previous Event
  previous: (event, onComplete) ->
    delay 0, -> onComplete event.previous

  # Get the following N events
  next: (event, onComplete) -> 
    delay 0, -> onComplete event.next

  # Compute the duration
  length: () => 
    @_length