require_relative "lib/lights_server"

lights = Lights::Server.new
lights.run
