import http
import iters

class Router {
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
  var method_routes = {
    'GET'    : {},
    'HEAD'   : {},
    'POST'   : {},
    'PUT'    : {},
    'DELETE' : {},
    'CONNECT': {},
    'OPTIONS': {},
    'PATCH'  : {},
    'TRACE'  : {}
  }

  serve(port) {
    var server = http.server(port)
    server.on_receive(|req, res| {
      var routes = self.method_routes[req.method]
      for path, fn in routes {
        var matches = req.path.match(path)
        if (matches) {
          # TODO: Remove by version v0.0.84 # https://github.com/blade-lang/blade/issues/153
          req.params = iters.reduce(matches.keys(), |original, key| {
            original[is_string(key) ? key.trim() : key] = matches[key]
            return original
          }, {})

          # req.params = matches
          fn(req, res)
          break
        }
      }
    })

    server.on_error(|err, _| {
      die err
    })

    echo 'server is running on http://localhost:3000'
    server.listen()
  }

  regex(path) {
    var wildcard = path.index_of('*')
    if (wildcard != -1 and wildcard != path.length() - 1) {
      die Exception('URL wildcard has to be the last character')
    }
    
    path = path.replace('/', '\\/').replace('*', '(?P<wildcard>.*)')
    var names = path.matches('/:(\w+)/')
    if (names) {
      var reserved = { 'wildcard': nil }
      
      for _, name in names[1] {
        if (reserved.get(name)) {
          die Exception('You cannot use the same name multiple times in a router path') 
        }
        reserved[name] = nil
        
        path = path.replace(':${name}', '(?P<${name}>[^\/]+)')
      }
    }
    return '/' + path + '$/'
  }

  _add(method, path, fn) {
    if (!is_string(path)) {
      die Exception('Unexpected path type. Expected a string')
    }

    if (!is_function(fn)) {
      die Exception('Unexpected function type. Expected a function')
    }

    self.method_routes[method][self.regex(path)] = fn
  }

  get(path, fn) {
    self._add('GET', path, fn)
  }

  head(path, fn) {
    self._add('HEAD', path, fn)
  }
  
  post(path, fn) {
    self._add('POST', path, fn)
  }

  put(path, fn) {
    self._add('PUT', path, fn)
  }

  delete(path, fn) {
    self._add('DELETE', path, fn)
  }
  
  connect(path, fn) {
    self._add('CONNECT', path, fn)
  }
  
  options(path, fn) {
    self._add('OPTIONS', path, fn)
  }

  patch(path, fn) {
    self._add('PATCH', path, fn)
  }

  trace(path, fn) {
    self._add('TRACE', path, fn)
  }
}
