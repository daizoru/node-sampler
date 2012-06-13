
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
Record = require './record'
Cursor = require './cursor'

# STREAMING API
class Recorder extends Stream
  constructor: (url="") ->
    log "stream.Recorder#constructor(#{url})"
    @record = simpleFactory Record, url

    @record.on 'close', =>
      @emit 'close'

  write: (data) ->
    @record.write data
  
class Player extends Stream
  constructor: (url, options) -> 
    log "stream.Player#constructor(#{url})"
    @config =
      rate: 1.0
      autoplay: on
      timestamp: no
      looped: no

    for k,v of options
      @config[k] = v

    @record = simpleFactory Record, url

    @cursor = new Cursor
      record: @record
      rate: @config.rate
      looped: @config.looped
      on:
        data: (timestamp, data) =>
          @emit 'data', data
        end: =>
          @emit 'end'
        error: (err) =>
          @emit 'end'
          @emit 'error', err
    if @config.autoplay
      @resume()

  resume: =>
    log "stream.Player#start()"
    @cursor.resume()

  pause: =>
    log "stream.Player#pause()"
    @cursor.pause()
