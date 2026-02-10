# Simple HTTP server with routing

http = require 'http'
url = require 'url'

routes = {}

get = (path, handler) ->
  routes[path] = handler

get '/', (req, res) ->
  res.writeHead 200, 'Content-Type': 'text/plain'
  res.end 'Hello, World!'

get '/api/time', (req, res) ->
  now = new Date().toISOString()
  res.writeHead 200, 'Content-Type': 'application/json'
  res.end JSON.stringify { time: now }

server = http.createServer (req, res) ->
  parsedUrl = url.parse req.url, true
  handler = routes[parsedUrl.pathname]
  if handler?
    handler req, res
  else
    res.writeHead 404
    res.end 'Not Found'

port = process.env.PORT or 3000
server.listen port, ->
  console.log "Server running on port #{port}"
