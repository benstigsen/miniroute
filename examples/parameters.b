import miniroute

var router = miniroute.Router()
router.get('/assets/*path', |request, response| {
  var path = request.params['path']
  response.write('Requested asset "${path}"')
})

router.get('/:firstname/:lastname', |request, response| {
  var firstname = request.params['firstname']
  var lastname  = request.params['lastname']
  response.write('Welcome ${firstname} ${lastname}!')
})

router.serve(3000)
