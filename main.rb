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
end

## Quick get to fill by colors
get '/fill/red/:red/blue/:blue/green/:green' do
  begin
    red = params[:red].to_i
    blue = params[:blue].to_i
    green = params[:green].to_i
  rescue
    red, blue, green = 129, 128, 128
  end
  $lights_server ||= Lights::Server.new
  data = { "status" => "on", "mode" => "fill", "color" => { "red" => red, "blue" => blue, "green" => green }}.to_json
  $lights_server.listen(data)
end
