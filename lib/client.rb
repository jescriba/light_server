require 'socket'
require 'json'

## Client to send json to light server
class Client

  def initialize

  end

  # Generate and send json to server from hash
  def send_hash(cmd_hash)
    json = JSON.generate(cmd_hash)
    send_json() 
  end 

end
