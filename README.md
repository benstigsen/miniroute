# Router

`router` is a tiny and lightweight routing library.

## Example

```js
import router
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


## Description
This routing library only makes use of the `http` module and the in-built regex matching.
It's not the most efficient way to do route matching, but for applications with few routes, it's 
more than powerful enough, for most use-cases.
