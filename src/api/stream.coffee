
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
moment = require 'moment'

# project modules
{delay,contains,simpleFactory} = require '../misc/toolbox'
Record = require '../record'
Cursor = require '../cursor'

# STREAMING API
class exports.Recorder extends Stream
  constructor: (url="",options={}) ->
    @config =
      autosave: 500
    for k,v of options
      @config[k] = v

    @synced = no
    @closed = no

    @writable = yes


    #log "StreamRecorder#constructor(#{url})"
    @record = simpleFactory Record, url

    @record.on 'error', (version, err) =>
      log "StreamRecorder: got error: #{err}"
      @emit 'error', err
      return

    @record.on 'synced', (version) =>
      #log "StreamRecorder: disk flushed, emitting'drain'"
      @synced = (version > 0) # we are synced if 
      #@emit 'drain' # not yet
      return


    if @config.autosave >= 0
      if @record.ready()
        delay @config.autosave, => @autosave()
      else
        @record.on 'ready', =>
          @autosave()
          

  autosave: =>
    #log "AUTOSAVE"
    if @synced
      # if we are closed AND synced -> stop loop
      if @closed
        @config.autosave = -1
        return
    else
      @record.sync()
    if @config.autosave >= 0
      delay @config.autosave, =>
        @autosave()

  end: (data) =>
    #log "StreamRecorder#end(#{inspect data})"
    @closed = yes
    @emit 'close' # optional
    #@record.close()

  # SimpleRecorder API
  write: (data) => 
    @synced = @record.write moment(), data

     # even iif we are not synced to disk, we let the input stream fill our buffer
    yes
  
class exports.Player extends Stream
  constructor: (url, options={}) -> 
    #log "StreamPlayer#constructor(#{url})"
    @config =
      speed: 1.0
      autoplay: yes
      withTimestamp: no
      looped: no

    @resumed = no

    for k,v of options
      @config[k] = v

    @record = simpleFactory Record, url

    @cursor = new Cursor
      record: @record
      speed: @config.speed
      looped: @config.looped

    @cursor.on 'begin', =>
      # ignore this for the moment

    if @config.withTimestamp
      @cursor.on 'data', (data) => @emit 'data', data
    else
      @cursor.on 'data', (data) => @emit 'data', data.data

    @cursor.on 'end', => @emit 'end'
    @cursor.on 'error', (err) =>
      #log "CURSOR SENT 'error': #{err}"
      @emit 'error', err

    if @config.autoplay
      if @record.ready()
        delay 0, => @resume()
      else
        @record.on 'ready', =>
          @resume()

  resume: =>
    #log "StreamPlayer#resume(): checking.."
    unless @resumed
      #log "...ok"
      @resumed = yes
      @cursor.resume()

  pause: =>
    #log "StreamPlayer#pause(): checking.."
    if @resumed
      #log "...ok"
      @resumed = no
      @cursor.pause()



