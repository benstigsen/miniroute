import miniroute { * }

def logging(request, response) {
  echo '${request.method} -> ${request.path}'
}

def homepage(request, response) {
  response.write('Welcome!')
}

var router = Router()

/* Logging middleware for all routes */
router.use(logging)

/* Basic authentication middleware */
router.get('/login', middleware.basicauth({'foo': 'bar'}), homepage)

/* Rate limiting middleware (3 requests in 30 seconds) */
router.get('/limit', middleware.ratelimit(3, 30), homepage)

/* Multiple middleware */
router.get('/all', middleware.ratelimit(3, 30), middleware.basicauth({'foo': 'bar'}), homepage)

router.serve(3000)
