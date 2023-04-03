import http

class RateLimiter {
  RateLimiter(amount, interval) {
    if (!is_number(amount)) {
      die Exception("ratelimit amount has to be a number specifying amount of requests allowed")
    }

    if (!is_number(interval)) {
      die Exception("ratelimit interval has to be a number of seconds")
    }

    self.user_requests = {}
    self.interval = interval
    self.amount = amount
  }

  add(id) {
    var current = time()
  
    var requests = self.user_requests.get(id)
    if (requests == nil) {
      self.user_requests[id] = [current]
      return true
    } else {
      while ((requests.length() > 0) and (requests[0] < (current - self.interval))) {
        requests.remove_at(0)
      }

      if (requests.length() < self.amount) {
        requests.append(current)
        return true
      }

      return false
    }
  }
}

def ratelimit(amount, interval) {
  var limiter = RateLimiter(amount, interval)

  return |request, response| {
    if (!limiter.add(request.ip)) {
      response.status = http.TOO_MANY_REQUESTS
      response.write('Too many requests')
      return false
    }
  }
}
