import .app { * }

var router = Router()
router.get('/', |request, response| {
  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Index!</h1>')
})

router.get('/:firstname/*', |request, response| {
  echo request.params
  var firstname = request.params.get("firstname")
  var lastname = request.params.contains("wildcard")

  for key, value in request.params {
    echo '"${key}" = "${value}"'
  }

  response.headers['Content-Type'] = 'text/html'
  response.write('<h1>Hello ${firstname} ${lastname}!</h1>')
})


router.serve(3000)
