require 'sinatra'
require 'json'
require 'pry'
#require_relative 'lib/lights_server.rb'

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
  "done"
end

get '/configuration' do
  $lights_server ||= Lights::Server.new
  content_type :json
  $lights_server.configuration
end

get '/random_range' do
  # TODO: Add a way to post the rate of random too
  erb :random_range
end

post '/random_range' do
  data = { setup: { mode: "random_range" }, mode_parameters: { red: {}, blue: {}, green:{} } }
  data[:mode_parameters][:red] = [params["red-min"].to_i, params["red-max"].to_i]
  data[:mode_parameters][:blue] = [params["blue-min"].to_i, params["blue-max"].to_i]
  data[:mode_parameters][:green] = [params["green-min"].to_i, params["green-max"].to_i]
  data_json = data.to_json
  $lights_server ||= Lights::Server.new
  $lights_server.listen(data_json)
  ''
end

get '/off' do
  $lights_server ||= Lights::Server.new
  $lights_server.clear()
  "off"
end
