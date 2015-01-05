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


# client code
# while true 
#   x = Message.new.status = "on"
#   Client.new.send_hash(x.cmd_hash)
# end
