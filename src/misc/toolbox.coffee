_ = require 'underscore'

delay = exports.delay = (t,f) -> setTimeout f, t

contains = exports.contains = (item, text) -> (text.indexOf(item) isnt -1)

simpleFactory = exports.simpleFactory = (Obj, params) ->    
  if params
    if _.isString params
      return new Obj params
    else
      return url
  else
    return new Obj()