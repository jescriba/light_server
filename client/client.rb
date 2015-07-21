## Quick wrapper to manage post requests via httparty
require 'timeout'
require 'httparty'
require 'json'

class ClientManager

  def check_kill_or_menu_command
    begin
      Timeout.timeout(0.01) do
        input = gets.chomp
        case input
        when "Q"
          abort("Closing")
        when "M"
          menu()
          @menu_called = true
        end
      end
      @menu_called
    rescue
      false
    end
  end

  def off
    red, green, blue = 128, 128, 128
    header = { 'Content-Type' => 'application/json' }
    body = { setup: { mode: "fill", clear: false }, color: { red: red, green: green, blue: blue } }.to_json
    HTTParty.post("http://192.168.1.112:4567/request", { :body => body, :headers => header })
  end

  def random(rate = 1)
    loop do
      check_kill_or_menu_command()
      break if @menu_called
      red = rand(128) + 128
      blue = rand(128) + 128
      green = rand(128) + 128
      header = { 'Content-Type' => 'application/json' }
      body = { setup: { mode: "fill", clear: false }, color: { red: red, green: green, blue: blue } }.to_json
      HTTParty.post("http://192.168.1.112:4567/request", { :body => body, :headers => header })
      sleep(rate.to_i)
    end
  end

  def incremental(red, green, blue)
    i = 0
    loop do
      i = 0 if i > 31
      colors = []
      32.times do |j|
        if j <= i
          colors.push({ red: red.to_i, green: green.to_i, blue: blue.to_i })
        else
          colors.push({ red: 128, green: 128, blue: 128 })
        end
      end
      header = { 'Content-Type' => 'application/json' }
      body = { setup: { mode: "custom", clear: false }, colors: colors }.to_json
      HTTParty.post("http://192.168.1.112:4567/request", { :body => body, :headers => header })
      i+=1
      sleep 0.1
    end
  end

  ## Randomly generates a color and stores it if you like it
  # in a text file
  def explore
    loop do
      sleep(1)
      check_kill_or_menu_command()
      break if @menu_called
      red = rand(128) + 128
      blue = rand(128) + 128
      green = rand(128) + 128
      header = { 'Content-Type' => 'application/json' }
      body = { setup: { mode: "fill", clear: false }, color: { red: red, blue: blue, green: green } }.to_json
      HTTParty.post("http://192.168.1.112:4567/request", { :body => body, :headers => header })
      puts "Save? Y/N/Q"
      input = gets.chomp
      if input == "Y"
        File.open("favorites.txt", "a") do |fi|
          fi.puts(red.to_s + "," + blue.to_s + "," + green.to_s)
        end
      elsif input == "Q"
        abort("closing")
      else
      end
    end
  end

  def falling(red, green, blue)
    i = 0
    loop do
      i = 0 if i > 31
      check_kill_or_menu_command()
      break if @menu_called
      header = { 'Content-Type' => 'application/json' }
      colors = []
      32.times do |j|
        if j == i or j == i - 1
          colors.push({ red: red.to_i, green: green.to_i, blue: blue.to_i})
        else
          colors.push({ red: 128, green: 128, blue: 128})
        end
      end
      body = { setup: { mode: "custom", clear: false }, colors: colors }.to_json
      HTTParty.post("http://192.168.1.112:4567/request", { :body => body, :headers => header })
      i += 3
      sleep(0.10)
    end
  end

  def striped(red1, green1, blue1, red2, green2, blue2)
    j = 0
    loop do
      j += 1
      check_kill_or_menu_command()
      break if @menu_called
      colors = []
      32.times do |i|
        if i % 2 == 0 && j % 2 == 0
          colors.push({ red: red1.to_i, green: green1.to_i, blue: blue1.to_i })
        else
          colors.push({ red: red2.to_i, green: green2.to_i, blue: blue2.to_i })
        end
      end
      header = { 'Content-Type' => 'application/json' }
      body = { setup: { mode: "custom", clear: false }, colors: colors }.to_json
      HTTParty.post("http://192.168.1.112:4567/request", { :body => body, :headers => header })
      sleep(0.5)
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
    @menu_called = false
    puts "##########################"
    puts "# Select command to run: #" 
    puts "# 1. Random              #"
    puts "# 2. Explore             #"
    puts "# 3. Striped             #"
    puts "# 4. Off                 #"
    puts "# 5. Falling             #"
    puts "# 6. incremental         #"
    puts "# M. Menu                #"
    puts "# Q. Quit                #"
    puts "##########################"
    input = gets.chomp
    case input
    when "1"
      puts "rate?"
      rate = gets.chomp
      rate.to_i
      random(rate)
    when "2"
      explore()
    when "3"
      puts "color1"
      red1, green1, blue1 = gets.chomp.split(",")
      puts "color2"
      red2, green2, blue2 = gets.chomp.split(",")
      striped(red1, green1, blue1, red2, green2, blue2)
    when "4"
      off()
    when "5"
      puts "color"
      red, green, blue = gets.chomp.split(",")
      falling(red, green, blue)
    when "6"
      puts "color"
      red, green, blue = gets.chomp.split(",")
      incremental(red, green, blue)
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
