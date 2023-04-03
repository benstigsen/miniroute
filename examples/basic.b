import miniroute

var router = miniroute.Router()
router.get('/', |request, response| {
  response.write('Created with miniroute!')
})

router.serve(3000)
