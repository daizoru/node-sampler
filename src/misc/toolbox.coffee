
YAML = require 'libyaml'


# we inline common dependencies here
# thus we don't get bloated by a tree of dozens of NPM dependencies 

isString = exports.isString = (obj) -> Object.prototype.toString.call(obj) is '[object String]'

delay = exports.delay = (t,f) -> setTimeout f, t

contains = exports.contains = (item, text) -> (text.indexOf(item) isnt -1)

# Get the first element of an array. Passing **n** will return the first N
# values in the array. Aliased as `head` and `take`. The **guard** check
# allows it to work with `_.map`.
first = exports.first = (array, n, guard) -> 
  (if (n?) and not guard then Array.prototype.slice.call(array, 0, n) else array[0])
 
# Get the last element of an array. Passing **n** will return the last N
# values in the array. The **guard** check allows it to work with `_.map`.
last  = exports.last = (array, n, guard) ->
  if (n?) and not guard
    Array.prototype.slice.call array, Math.max(array.length - n, 0)
  else
    array[array.length - 1]

simpleFactory = exports.simpleFactory = (Obj, params) ->    
  if params
    if isString params
      return new Obj params
    else
      return params
  else
    return new Obj()

loadFile = exports.loadFile = (path, cb) ->
  switch path.split(".")[-1..].toLowerCase()
    when "js", "json"
      fs.readFile path, (err, raw) =>
        if err?
          cb err, {}
        else
          cb no, JSON.parse(raw)
    when "yml", "yaml" 
      YAML.readFile path, (err, obj) => 
        if err?
          cb err, {}
        else
          cb no, obj[0]
    else
      fs.readFile path, (err, raw) =>
        if err?
          cb err, {}
        else
          cb no, "#{raw}".split "\n"
