## Quick wrapper to manage post requests via httparty
require 'httparty'
require 'json'

#puts "Assuming mode is fill"
#puts "r, g, b"
#red, green, blue = gets.chomp.split(",").map { |el| el.to_i }
while true
  red = rand(128) + 128
  blue = rand(128) + 128
  green = rand(128) + 128
  header = { 'Content-Type' => 'application/json' }
  body = { "status" => "on", "mode" => "fill", "color" => { "red" => red, "blue" => blue, "green" => green } }.to_json
  HTTParty.post("http://10.0.0.14:4567/request", { :body => body, :headers => header })
  sleep(0.1)
end
