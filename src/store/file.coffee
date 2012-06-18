
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


### TODO use async, streaming file reading:

writeStream = fs.createWriteStream(__dirname + "/outFile.txt");
// every time "data" is read, this event fires
readStream.on('data', function(textData) {
  console.log("Found some text!");
  writeStream.write(textData);
});

// the reading is finished...
readStream.on('close', function () {
  writeStream.end(); // ...close up the write, too!
  console.log("I finished.");
});


"Partially buffered access methods are different. 
They do not treat data input as a discrete event, 
but rather as a series of events which occur as 
the data is being read or written. They allow us
to access data as it is being read from 
disk/network/other I/O.
Partially buffered methods, such as readSync() 
and read() allow us to specify the size of the
buffer, and read data in small chunks. They
allow for more control (e.g. reading a file in
non-linear order by skipping back and forth in
the file)." (from http://book.mixu.net/ch9.html)

###

# TODO emit errors when there are.. errors
class module.exports extends Memory
  constructor: (@path, options={}) ->

    # copied from memory
    @config =
      filename: ->
    
    for k,v of options
      @config[k]=v

    @events = []
    @first = no
    @last = no
    @_length = 0

    # file version start here

    @buff = []
    @buffMax = 1
    @isWriting = no
    @initialized = no
    @flushing =
      version: 1
      saved: 0

    # TODO: smarter IO (eg. only append to existing file)
    @format = getFormat @path
    switch @format
      when "YAML"
        #log "using YAML"
        @saveSnapshot = YAML.writeFile
        @loadSnapshot = YAML.readFile
      when "JSON"
        #log "using JSON"
        @saveSnapshot = (path, data, cb) =>
          dumpString = JSON.stringify data 
          fs.writeFile path, dumpString, (err) => 
            cb err
        @loadSnapshot = (path, cb) =>
          fs.readFile path, (err, data) => 
            obj = {}
            unless err
              try
                obj = JSON.parse data
              catch exc
                err = "could not load json: #{exc}"

            cb err, obj

      when "SAMPLER"
        @saveSnapshot = (path, data, cb) =>
          #log "File: saving snapshot using Snappy"
          compressed = snappy.compressSync data
          fs.writeFile path, compressed, (err) => 
            cb err

        @loadSnapshot = (path, cb) =>
          fs.readFile path, (err, raw) => 
            obj = {}
            unless err
              data = snappy.decompressSync raw, snappy.parsers.string
              #log "data: #{data}"
              if data
                try
                  #log "GOING TO PARSE #{data}"
                  obj = JSON.parse data
                catch exc
                  err = "invalid json file: #{exc}"
            #log "obj: #{obj}"
            cb err, obj

      else
        log "unknow format: #{@format}"
        throw "unknow format: #{@format}"
        return

    delay 1, => @load()



  # async load - the stream will resume once the file is loaded
  load: ->
    #log "LOADING FILE.."
    @loadSnapshot @path, (err, data) =>

     if err

        #msg = "could not load '#{@path}': #{err}"
        #error msg
        #throw msg
        #log "file empty?"
        1


      if data?
        #log "got data: #{data}"
        if data.events?
          #log "got events"
          if data.events.length > 0
            #log "Loading events.."
            #log "loading #{data.events}"

            # TODO: WARNING: we might already have some events in the memory
            # for the moment we simply ignore previous entries
            @events = []

            for event in data.events
              @write moment(event[0]), event[1]
      #log "inspection: #{inspect @events}"
      @ready()

  sync: =>
    #log "FILE: SYNC: POSSIBLE?"
    unless @initialized
      #log "cannot sync: file is not initialized. aborting"
      @emit 'synced', -1
      # TODO: we should save later..
      return

    if @isWriting
      #log "cannot sync: file is already been synced. aborting"
      @emit 'synced', -1
      #log "CANNOT SAVE NOW - PLEASE TRY LATER"
      return

    #log "SYNC POSSIBLE"
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

    #log "WRITING TO DISK VERSION #{version}: (#{@path}, #{snapshot})"
    version = @count
    @saveSnapshot @path, snapshot, (err) =>
      @flushing.saved = version
      @isWriting = no
      if err
        #error "store.File: ERROR, COULD NOT WRITE TO FILE: #{err}"
        @emit 'synced', -1
        @emit 'error', err
      else
        #log "file synced to #{version}"
        @emit 'synced', version


  _writeEvent: (event) =>
    #log "WRITING EVENT"
    @events.push event
    @buff.push event
    @count()
    no

