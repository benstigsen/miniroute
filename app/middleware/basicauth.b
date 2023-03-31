import http
import base64

def _fail(request, response) {
  response.headers['WWW-Authenticate'] = 'Basic realm="Login Required"'
  response.status = http.UNAUTHORIZED
  response.write('Login Required')
}

def basicauth(credentials) {
  if (!is_dict(credentials)) {
    die Exception('basicauth credentials has to be a dictionary of type {string: string}')
  }

  for username, password in credentials {
    if (!is_string(username) or !is_string(password)) {
      die Exception('basicauth credentials has to be a dictionary of type {string: string}')
    }
  }

  return |request, response| {
    var auth = request.headers.get('Authorization')
    if (auth == nil) {
      _fail(request, response)
      return false
    }

    var decoded = base64.decode(auth.split(' ')[1]).to_string().split(':')
    var username = decoded[0]
    var password = decoded[1]

    var credpass = credentials.get(username)
    if (credpass == nil or credpass != password) {
      _fail(request, response)
      return false
    }

    return true
  }
}
