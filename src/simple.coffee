
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
{delay,contains,simpleFactory} = require './misc/toolbox'
{Record} = require './record'

# SIMPLE API
class Recorder
  constructor: (url=no) ->
    log "simple.Recorder#constructor(#{url})"
    @record = simpleFactory Record, url


  # SimpleRecorder API
  write: (data,status=->) => 
    log "SimpleRecorder#write(#{data})"
    @record.write moment(), data, status

  # SimpleRecorder API
  writeAt: (timestamp, data,status=->) => 
    log "SimpleRecorder#writeAt(#{timestamp},#{data})"
    @record.write timestamp, data, status
  
class Player
    constructor: (url, options) -> 
    log "simple.Player#constructor(#{url}, options)"

    @config =
      rate: 1.0
      autoplay: on
      timestamp: no
      looped: no
      onData: (event) -> log "#{event.timestamp}: #{event.data}"
      onEnd: ->
      onError: (err) ->

    for k,v of options
      @config[k] = v

    @record = simpleFactory Record, url

    @cursor = new Cursor
      record: @record
      rate: @config.rate
      looped: @config.looped
      on:
        data: (timestamp, data) =>
          @config.onData timestamp, data
        end: =>
          @config.onEnd()
        error: (err) =>
          @config.onEnd()
          @config.onError err

    if @config.autoplay
      @start()

  start: ->
    log "simple.Player#start()"
    @cursor.resume()
