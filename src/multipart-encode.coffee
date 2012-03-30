_flatten = (q) ->
  list = []
  Object.keys(q).forEach (k) ->
    v = q[k]
    if k[0] is "$"
      k = k.slice(1)
      if k[0] isnt "$"
        v = JSON.stringify(v)
    [].concat(v).forEach (v) ->
      list.push [ k, v ]
  list


exports.multipartEncode = (data) ->

  buffer = new Buffer(0)

  push   = (l) ->
    prevBuffer = buffer
    newBuffer = (if (l instanceof Buffer) then l else new Buffer("" + l))
    buffer = new Buffer(prevBuffer.length + newBuffer.length + 2)
    prevBuffer.copy buffer
    newBuffer.copy buffer, prevBuffer.length
    buffer.write "\r\n", buffer.length - 2

  q = (s) -> "\"" + s.replace(/"|"/g, "%22").replace(/\r\n|\r|\n/g, " ") + "\""

  segno = "" + Math.round(Math.random() * 1e16) + Math.round(Math.random() * 1e16)

  _flatten(data).forEach (kv) ->
    push "--" + segno
    if {}.hasOwnProperty.call(kv[1], "data")
      file = kv[1]
      push "Content-Disposition: form-data; name=" + q(kv[0]) + "; filename=" + q(file.name or "blob")
      push "Content-Type: " + (file.type or "application/octet-stream")
      push ""
      push file.data
    else
      push "Content-Disposition: form-data; name=" + q(kv[0])
      push ""
      push kv[1]

  push "--" + segno + "--"

  buffer: buffer
  boundary: segno

