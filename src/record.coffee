
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
# {Stream} = require 'stream'
events = require 'events'
# third party modules
moment = require 'moment'

# project modules
{delay,contains} = require './misc/toolbox'
stores = require './stores'

class module.exports extends events.EventEmitter

  constructor: (url="", options) ->
    @config =
      autosave: -1

    for k,v of options
      @config[k]=v

    @waiting = []

    # default store
    @store = new stores.Memory @config

    # more esoteric ones
    if contains "file://", url
      path = url.split("file://")[1]
      log "Record(#{url}) -> PATH #{path}"
      @store = new stores.File path, @config

    # 
    @store.on 'error', (err) =>
      error "Record: @store sent us an error: #{err}"
      @emit 'error', err

    @store.on 'flushed', =>
      error "Record: @store has flushed"
      @emit 'flushed'
      # we use a delay for each entry, since @waiting might be very long
      for cb in @waiting
        delay 0, -> cb {}
      @waiting = []


  length: (cb=no) => 
    @store.length cb

  # write to the database. Return yes if flushed, no if uncertain.
  # status is called when the entry is really written to the base,
  # or if something bad happened
  write: (timestamp, data, cb=no) => 
    log "Record: write()"
    @waiting.push cb if cb
    @store.write timestamp, data

  save: (cb=no) =>
    log "Record: save()"
    @waiting.push cb if cb
    @store.save()
