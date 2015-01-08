require 'sinatra'
require 'json'
require 'pry'
require_relative 'lib/lights_server.rb'

set :bind, '0.0.0.0'

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
