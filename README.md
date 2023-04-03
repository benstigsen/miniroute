# miniroute
`miniroute` is a simple routing library with the following features:
- Named parameters
  - `/blog/:category/:title`
  - `/asset/*path`
- Middleware support (`basicauth`, `ratelimit` and custom functions)
- No external dependencies (uses default `http` and `reflect` modules)

## Example

```javascript
import miniroute { Router }
import mime

var router = Router()
router.get('/', |request, response| {
  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Index!</h1>')
})

/* Wilcard Routes */
router.get('/assets/*path', |request, response| {
  var path = request.params['path']
  var type = mime.detect_from_name(path)

  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Asset ${path} has mimetype ${type}</h1>')
})

/* Named Routes */
router.get('/:firstname/:lastname', |request, response| {
  var firstname = request.params['firstname']
  var lastname  = request.params['lastname']

  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Hello ${firstname} ${lastname}!</h1>')
})

router.serve(3000)
```

1. `localhost:3000/` will show `Index!`.
3. `localhost:3000/assets/css/style.css` will show `Asset css/style.css has mimetype text/css`
2. `localhost:3000/John/Smith` will show `Hello John Smith!`

Wildcard parameters always have to be at the end of the URL path.

## Middleware
Middleware is supported to allow for easy logging, verification, etc.

If your middleware function returns `false`, then it won't continue to the next method.
```python
import miniroute { * } # { Router, middleware }

def log(request, response) {
  echo '${request.ip} => ${request.path}'
}

def homepage(request, response) {
  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Welcome!</h1>')
}

var router = Router()

# Global middleware (logging for all routes)
router.use(log)

# Basic auth middleware, login with username "foo" and password "bar"
router.get('/', middleware.basicauth({'foo': 'bar'}), homepage)

router.serve(3000)
```

Using `router.use()` adds middleware to every single server request.
So in the example above, every request is being printed to the console.

There's also some built-in middleware like `basicauth()` and `ratelimit()` making it easy
to add login authentication and more security to the module.
