
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
{delay,contains} = require '../misc/toolbox'
BinaryTree = require '../misc/btree'

class MemoryStore
  constructor: () ->
    @events = []
    @first = no
    @last = no

  insert: (event) =>
    # for the moment, we can only manage insertion at the end
    # TODO later: use https://github.com/vadimg/js_bintrees
    first = _.first @events
    first = event unless first
    first.previous = event
    event.next = first
    @first = first

    last = _.last @events
    last = event unless last
    last.next = event
    event.previous = last
    @last = last

    @events.push event

  # Get the previous Event
  previous: (event, onComplete) ->
    delay 0, -> onComplete event.previous

  # Get the following Event
  next: (event, onComplete) -> 
    delay 0, -> onComplete event.next

  # Compute the duration
  duration: -> if @first and @last then @last.timestamp - @first.timestamp else 0