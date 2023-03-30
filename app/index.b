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

  var global_routes = []

  serve(port) {
    var server = http.server(port)
    server.on_receive(|req, res| {
      var routes = self.method_routes[req.method]
      for path, arr in routes {
        var matches = req.path.match(path)
        if (matches) {
          # TODO: Remove by version v0.0.84 # https://github.com/blade-lang/blade/issues/153
          req.params = iters.reduce(matches.keys(), |original, key| {
            original[is_string(key) ? key.trim() : key] = matches[key]
            return original
          }, {})

          for fn in self.global_routes {
            if (fn(req, res) == false) {
              break
            }
          }

          # req.params = matches
          for fn in arr {
            if (fn(req, res) == false) {
              break
            }
          }
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

  _add(method, path, functions) {
    if (!is_string(path)) {
      die Exception('Unexpected route path type. Expected a string')
    }

    for fn in functions {
      if (!is_function(fn)) {
        die Exception('Unexpected function type in route "${path}". Expected a function of type function(request, response)')
      }
    }

    self.method_routes[method][self.regex(path)] = functions
  }

  use(...) {
    for fn in __args__ {
      if (!is_function(fn)) {
        die Exception('Unexpected function type in router.use(). Expected a function of type function(request, response)')
      }
    }
    self.global_routes.extend(__args__)
  }

  get(path, ...) {
    self._add('GET', path, __args__)
  }

  head(path, ...) {
    self._add('HEAD', path, __args__)
  }
  
  post(path, ...) {
    self._add('POST', path, __args__)
  }

  put(path, ...) {
    self._add('PUT', path, __args__)
  }

  delete(path, ...) {
    self._add('DELETE', path, __args__)
  }
  
  connect(path, ...) {
    self._add('CONNECT', path, __args__)
  }
  
  options(path, ...) {
    self._add('OPTIONS', path, __args__)
  }

  patch(path, ...) {
    self._add('PATCH', path, __args__)
  }

  trace(path, ...) {
    self._add('TRACE', path, __args__)
  }
}
