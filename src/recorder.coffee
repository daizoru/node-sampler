
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
moment = require 'moment'

contains = (item, text) -> (text.indexOf(item) isnt -1)
class Database
  constructor: (@recorder=no) ->
  
  insert: (time, event) ->

class InMemory extends Database
  constructor: (@args) ->
    super()

  insert: (time, event) ->
    rawString = JSON.stringify time: time, event: event

class SimpleFile extends Database
  constructor: (@args) ->
    super()

  insert: (time, event) ->
    rawString = JSON.stringify time: time, event: event


class PlaybackModule

  constructor: (@main) ->

    # give playback capabilities to the main class
    @main.play = (rate=1.0) => 
      @main.database.insert moment(), event

    @main.recordAt = (time, event) => 
      @main.database.insert moment(time), event

class RecordModule

  constructor: (@main) ->

    # give record capabilities to the main class
    @main.record = (event) => 
      @main.database.insert moment(), event

    @main.recordAt = (time, event) => 
      @main.database.insert moment(time), event

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
    
