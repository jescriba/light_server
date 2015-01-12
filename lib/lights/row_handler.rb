## Handles the SPI and Row Status
#
require 'pi_piper'
require_relative 'light.rb'

module Lights
  class RowHandler
    include PiPiper, Colors
    attr_reader :lights_array, :command_history
   
    NUM_OF_LEDS = 32
    @@modes = [:default, :fill, :fluctuate]
    
    def initialize
      @lights_array = []
      @command_history = []
      NUM_OF_LEDS.times do |i|
        @lights_array.push(Light.new(status = false))
      end
      # Initialize quick light up for visual inspection
      setup_test()
    end

    def update(instructions)
      @web_request = instructions
      @command_history.push([Time.now, instructions])
      @command_history.shift(30) if @command_history.size > 300
      mode = instructions["mode"]
      mode = mode.downcase.to_sym if mode.is_a?(String)
      method(mode).call if @@modes.include?(mode)
    end

    ## TODO: Record of what the current json 
    # status of what the lights configuration is
    def status
      @command_history.last
    end

    # Default lights once RowHandler is created
    def setup_test
      # Flash lights
      fill(Color.new(red: 128, green: 250, blue: 128))
      sleep(3)
      fill(Color.new(red: 128, green: 128, blue: 128))
    end

    ## Uses the light array configurations to construct the byte message
    # to send to spi device
    def led_message()
      msg = []
      @lights_array.each do |light|
        light.color.normalize
        color = light.color
        #if !light.status
        #  msg.push([128, 128, 128]) # Off
        #else
          msg.push([color.green, color.red, color.blue])
        #end
      end
      msg.flatten!
      msg = Array.new(3 * NUM_OF_LEDS, 128) if msg.size != 3 * NUM_OF_LEDS
      msg.unshift(0, 0, 0)
    end

    ###########################
    # Methods for Light Modes #
    ###########################
    def default
      fill(Color.new(red: 140, green: 140, blue: 140))
    end

    def fill(color = nil)
      if !@web_request.nil?
        color = @web_request["color"] if @web_request
        red = color["red"]
        blue = color["blue"]
        green= color["green"]
        color = Color.new(red: red.to_i, green: green.to_i, blue: blue.to_i)
      end
      # Set all the light colors to the specified color
      @lights_array.each do |light|
        light.color = color
      end
      # Write to LED strip
      msg = led_message()
      PiPiper::Spi.begin do
          puts write((msg))
      end
    end

    def custom_static
      @lights_array.each_with_index do |light, index|
        request_color = @web_request["colors"][index]
        if !request_color.nil?
          red = request_color["color"]["red"] || 128
          blue = request_color["color"]["blue"] || 128
          green = request_color["color"]["green"] || 128
          color = Color.new(red: red.to_i, blue: blue.to_i, green: green.to_i)
        else
          color = Color.new(red: 128, blue: 128, green: 128)
        end
        end
        light.color = color
      end
      msg = led_message()
      PiPiper::Spi.begin do
        puts write(msg)
      end
    end

    def fluctuate
    end

    def custom
    end

  end
end
