
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

# STREAMING API
class Recorder extends Stream
  constructor: (url="") ->
    if url
      if _.isString url
        @record = new Record url
      else
        @record = url
    else
      @record = new Record()
  
class Player extends Stream
  constructor: (@record, options) -> 
    @config =
      rate: 1.0
      autoplay: on
      timestamp: no
    for k,v of options
      @config[k] = v

    if @config.autoplay
      @play @config.rate

    @record.on 'data', (data) =>
      if @config.timestamp
        @emit 'data', 

  play: (rate=no) ->
    r = if rate then rate else @rate
    @record.startStream r

#recorder = new StreamRecorder()
#input.pipe(recorder)

# at any time, you can have access to the inner record
#recorder.record

#player = new StreamPlayer(record)
#player.pipe(output)