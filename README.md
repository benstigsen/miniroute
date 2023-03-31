# Router
`router` is a tiny and lightweight routing library.

## Description
This routing library only makes use of the `http` module and the in-built regex matching.
It's not the most efficient way to do route matching, but for applications with few routes, it's 
more than powerful enough, for most use-cases.

## Example
```javascript
import router { Router }
import mime

var router = Router()
router.get('/', |request, response| {
  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Index!</h1>')
})

# Wildcard
router.get('/assets/*', |request, response| {
  var path = request.params['wildcard']
  var type = mime.detect_from_name(path)

  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Asset ${path} has mimetype ${type}</h1>')
})

# Named
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

## Middleware
Middleware is supported to allow for easy logging, verification, etc.

If your middleware function returns `false`, then it won't continue.
```python
import router { Router, middleware }

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

There's also some built-in middleware like `basicauth()` making it easy
to add login authentication to the module.
