
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
{Stream} =            require 'stream'
events =              require 'events'
fs =                  require 'fs'

# third party modules
moment =              require 'moment'
YAML =                require 'libyaml'
snappy =              require 'snappy'

# project modules
{delay,contains} =    require '../misc/toolbox'
BinaryTree =          require '../misc/btree'
Memory =              require './memory'

getFormat = (path) ->
  return "UNKNOW" unless path
  switch path.split?(".")[-1..][0].toLowerCase?()
    when "js", "json"
     "JSON"
    when "yml", "yaml" 
      "YAML"
    when "smp","sample"
      "SAMPLER"
    else
      "UNKNOW"

# TODO emit errors when there are.. errors
class module.exports extends Memory
  constructor: (@path) ->
    super()
    @buff = []
    @buffMax = 3
    @isWriting = no

    # TODO: smarter IO (eg. only append to existing file)
    @format = getFormat @path
    switch @format
      when "YAML"
        log "using YAML"
        @saveSnapshot = YAML.writeFile
      when "JSON"
        log "using JSON"
        @saveSnapshot = (path, data, cb) =>
          dumpString = JSON.stringify data 
          fs.writeFile path, dumpString, (err) ->
            cb err
      when "SAMPLER"
        @saveSnapshot = (path, data, cb) =>
          #log "File: saving snapshot using Snappy"
          dumpString = YAML.stringify data
          compressedBuffer = snappy.compressSync dumpString
          fs.writeFile path, compressedBuffer, (err) ->
            cb err

      else
        log "unknow format: #{@format}"
        throw "unknow format: #{@format}"
        return

  # async load - the stream will resume once the file is loaded
  _load: (path, cb=->) ->
    # use YAML.stream.parse
  
  _writeEvent: (event) =>
    @events.push event
    @buff.push event

    if @buff.length >= @buffMax
      if @isWriting
        log "cannot flush right now, previous flushing is still in progress.."
        return no

      log "buffer max reached -> flushing to disk"

      @isWriting = yes

      # serialize references
      snapshot =
        # don't serialize what can be inferred
        #first: 0+@first.timestamp
        #last: 0+@last.timestamp
        events: []
      @buff = []
      for event in @events
        snapshot.events.push [
          0+event.timestamp
          # don't serialize what can be inferred
          #previous: 0+event.previous.timestamp
          #next: 0+event.next.timestamp
          event.data
        ]

      log "calling fsWrite with (#{@path}, #{snapshot})"
      @saveSnapshot @path, snapshot, (err) =>
        @isWriting = no
        if err
          #log "store.File: _writeEvent: could not write events to disk.."
          @emit 'error', err
        else
          #log "store.File: _writeEvent: events wrote to disk! sending flushed=yes.."
          @emit 'flushed'
      no # tell the stream our buffer is full, and he must stop
    # else we resume
    else
      yes
