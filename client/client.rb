## Quick wrapper to manage post requests via httparty
require 'timeout'
require 'httparty'
require 'json'

class ClientManager

  def check_kill_or_menu_command
    menu_called = false
    begin
      Timeout.timeout(0.01) do
        input = gets.chomp
        case input
        when "Q"
          abort("Closing")
        when "M"
          menu()
          menu_called = true
        end
      end
    rescue
    end
    menu_called
  end

  def random(rate = 1)
    loop do
      check_kill_or_menu_command()
      red = rand(128) + 128
      blue = rand(128) + 128
      green = rand(128) + 128
      header = { 'Content-Type' => 'application/json' }
      body = { "status" => "on", "mode" => "fill", "color" => { "red" => red, "blue" => blue, "green" => green } }.to_json
      HTTParty.post("http://10.0.0.14:4567/request", { :body => body, :headers => header })
      sleep(rate)
    end
  end

  ## Randomly generates a color and stores it if you like it
  # in a text file
  def explore
    loop do
      sleep(1)
      check_kill_or_menu_command()
      red = rand(128) + 128
      blue = rand(128) + 128
      green = rand(128) + 128
      header = { 'Content-Type' => 'application/json' }
      body = { "status" => "on", "mode" => "fill", "color" => { "red" => red, "blue" => blue, "green" => green } }.to_json
      HTTParty.post("http://10.0.0.14:4567/request", { :body => body, :headers => header })
      puts "Save? Y/N/Q"
      input = gets.chomp
      if input == "Y"
        File.open("favorites.txt", "w") do |fi|
          fi.puts(red.to_s + "," + blue.to_s + "," + green.to_s)
        end
      elsif input == "Q"
        abort("closing")
      else
      end
    end
  end

  ## Select a favorited color
  def select_favorite

  end

  ## Toggles through previously explored colors that are favorited
  def toggle_favorites
    check_kill_or_menu_command()
  end

  def menu
    puts "##########################"
    puts "# Select command to run: #" 
    puts "# 1. Random              #"
    puts "# 2. Explore             #"
    puts "# M. Menu                #"
    puts "# Q. Quit                #"
    puts "##########################"
    input = gets.chomp
    case input
    when /1/
      rate = 1
      rate = rate.split("rate:")[1] if input.include?("rate:")
      random(rate)
    when "2"
      explore()
    else 
      abort("Closing")
    end
  end

  def run
    menu()
  end
end

puts "Running client"
client = ClientManager.new()
client.run()
