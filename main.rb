require 'sinatra'
require 'json'
require 'pry'
require_relative 'lib/lights_server.rb'

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
  ""
end

get '/configuration' do
  $lights_server ||= Lights::Server.new
  content_type :json
  $lights_server.configuration
end

get '/off' do
  $lights_server ||= Lights::Server.new
  $lights_server.clear()
end
