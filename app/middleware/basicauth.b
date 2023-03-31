import http
import base64

def basicauth(credentials) {
  if (!is_dict(credentials)) {
    die Exception('basic_auth credentials has to be a dictionary of type {string: string}')
  }

  return |request, response| {
    var auth = request.headers.get('Authorization')
    if (auth == nil) {
      response.headers['WWW-Authenticate'] = 'Basic realm="Login Required"'
      response.status = http.UNAUTHORIZED
      response.write('Login Required')
      return false
    }

    var decoded = base64.decode(auth.split(' ')[1]).to_string().split(':')
    var username = decoded[0]
    var password = decoded[1]

    var credpass = credentials.get(username)
    if (credpass == nil or credpass != password) {
      response.headers['WWW-Authenticate'] = 'Basic realm="Login Required"'
      response.status = http.UNAUTHORIZED
      response.write('Login Required')
      return false
    }

    return true
  }
}
