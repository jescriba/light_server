require 'sinatra'
require 'json'

get '/' do
  erb :home
end

get '/reset' do
  erb :home
end

post '/request' do
  $lights_server ||= Lights::Server.new
  req = JSON.parse(request.body.read)
  data = req.to_json
  $lights_server.listen(data)
end
