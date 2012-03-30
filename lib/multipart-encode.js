function getFormDataForPost(fields, files) {
  function encodeFieldPart(boundary,name,value) {
    var return_part = "--" + boundary + "\r\n";
    return_part += "Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n";
    return_part += value + "\r\n";
    return return_part;
  }
  function encodeFilePart(boundary,type,name,filename) {
    var return_part = "--" + boundary + "\r\n";
    return_part += "Content-Disposition: form-data; name=\"" + name + "\"; filename=\"" + filename + "\"\r\n";
    return_part += "Content-Type: " + type + "\r\n\r\n";
    return return_part;
  }
  var boundary = Math.random();
  var post_data = [];
 
  if (fields) {
    for (var key in fields) {
      var value = fields[key];
      post_data.push(new Buffer(encodeFieldPart(boundary, key, value), 'ascii'));
    }
  }
  if (files) {
    for (var key in files) {
      var value = files[key];
      post_data.push(new Buffer(encodeFilePart(boundary, value.type, value.keyname, value.valuename), 'ascii'));
 
      post_data.push(new Buffer(value.data, 'utf8'))
    }
  }
  post_data.push(new Buffer("\r\n--" + boundary + "--"), 'ascii');
  var length = 0;
 
  for(var i = 0; i < post_data.length; i++) {
    length += post_data[i].length;
  }
  var params = {
    postdata : post_data,
    headers : {
      'Content-Type': 'multipart/form-data; boundary=' + boundary,
      'Content-Length': length
    }
  };
  return params;
}

module.exports = getFormDataForPost;
