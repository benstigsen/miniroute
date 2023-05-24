import http
import iters
import reflect
import .middleware

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
  var error_fn = |err, _| {
    die err
  }

  serve(port) {
    var server = http.server(port)
    server.on_receive(|req, res| {
      var routes = self.method_routes[req.method]
      for path, arr in routes {
        var matches = req.path.match(path)
        if (matches) {
          req.params = matches

          for fn in self.global_routes {
            if (fn(req, res) == false) {
              break
            }
          }

          for fn in arr {
            if (fn(req, res) == false) {
              break
            }
          }
          break
        }
      }
    })

    server.on_error(self.error_fn)

    echo 'server is running on http://localhost:3000'
    server.listen()
  }

  on_error(fn) {
    self.error_fn = fn
  }

  regex(path) {
    path = path.replace('/', '\\/')

    var reserved = []

    var wildcard = path.match('/\*(\w+)$/')
    if (wildcard) {
      path = path.replace(wildcard[0], '(?P<${wildcard[1]}>.*)')
      reserved.append(wildcard[1])
    }

    var names = path.matches('/:(\w+)/')
    if (names) {
      for _, name in names[1] {
        path = path.replace(':${name}', '(?P<${name}>[^\/]+)')
        reserved.append(name)
      }
    }

    for name in reserved {
      assert reserved.count(name) == 1, 'You cannot use the same parameter name "${name}" multiple times in a router path'
    }

    return '/' + path + '$/'
  }

  _verify_fn(fn) {
    assert is_function(fn), 'Unexpected function type for route. Expected a function of type function(request, response)'

    var info = reflect.get_function_metadata(fn)
    assert info['arity'] == 2, 'Invalid router function ${info["name"]}, expected 2 arguments (request, response) instead of ${info["arity"]}.'
  }

  _add(method, path, functions) {
    assert is_string(path), 'Unexpected route path type. Expected a string'

    for fn in functions {
      self._verify_fn(fn)
    }

    self.method_routes[method][self.regex(path)] = functions
  }

  use(...) {
    for fn in __args__ {
      self._verify_fn(fn)
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
