## Handles the SPI and Row Status
#
require 'pi_piper'
require 'pry'
require_relative 'light.rb'

module Lights
  class RowHandler
    include PiPiper, Colors
    attr_reader :lights_array, :command_history, :setup, :mode, :clear
   
    NUM_OF_LEDS = 32
    @@modes = [:default, :fill, :fluctuate, :custom, :clear_lights]
    
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
      parse_request(instructions)
      @command_history.push([Time.now, instructions])
      @command_history.shift(30) if @command_history.size > 300
      @mode = @mode.downcase.to_sym if mode.is_a?(String)
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
      fill(Color.new(red: 165, green: 133, blue: 155))
    end

    def fill(color = nil)
      clear_lights() if @clear
      unless @color.nil?
        color ||= Color.new(@color["red"], @color["blue"], @color["green"])
      end
      @lights_array.each do |light|
        light.color = color
      end
      # Write to LED strip
      msg = led_message()
      PiPiper::Spi.begin do
          puts write((msg))
      end
    end

    def custom
      clear_lights() if @clear
      @colors.each_with_index do |raw_color, i|
        red = raw_color["red"] || 128
        blue = raw_color["blue"] || 128
        green = raw_color["green"] || 128
        color = Color.new()
        if i < NUM_OF_LEDS - 1
          @lights_array[i].color = color
        end
      end
      msg = led_message()
      PiPiper::Spi.begin do
        puts write(msg)
      end
    end

    def fluctuate
    end

    def clear_lights
      @lights_array.each do |light|
        light.color = Color.new(red: 128, blue: 128, green: 128)
      end
      msg = led_message()
      PiPiper::Spi.begin do
        puts write(msg)
      end
    end

    private

    def parse_request(instructions)
      @setup = instructions["setup"] || @setup
      @mode = @setup["mode"] || @mode
      clear_lights() if @mode == "off"
      @clear = @setup["clear"] || @clear
      @colors = instructions["colors"] || @colors
      @color = instruction["color"] || @color
    end

  end
end
