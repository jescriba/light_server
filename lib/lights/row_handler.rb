## Handles the SPI and Row Status
#
require 'pi_piper'
require 'timeout'
require 'pry'
require_relative 'light.rb'

module Lights
  class RowHandler
    include PiPiper, Colors
    attr_reader :lights_array, :command_history, :setup, :mode, :clear,
      :animation_threads
   
    NUM_OF_LIGHTS = 32
    START_TIME = 14
    STOP_TIME = 24
    @@modes = [:default, :fill, :fluctuate, :custom, :clear_lights, 
    :round_trip]
    
    def initialize
      @animation_threads = []
      @lights_array = []
      @command_history = []
      NUM_OF_LIGHTS.times do |i|
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
        msg.push([color.green, color.red, color.blue])
      end
      msg.flatten!
      msg = Array.new(3 * NUM_OF_LIGHTS, 128) if msg.size != 3 * NUM_OF_LIGHTS
      msg.unshift(0, 0, 0)
    end

    # Return json of the current configuration
    def configuration
      config = {}
      config[:colors] = @colors
      config[:color] = @color
      config[:setup] = @setup 
      config[:lights] = @lights_array.map do |light|
        c = light.color
        "red: #{c.red}, blue: #{c.blue}, green: #{c.green}"
      end
      config.to_json
    end

    def kill_animations
      unless @animations_threads.empty?
        @animation_threads.each { |t| t.kill }
        @animation_threads = []
      end
    end

    ###########################
    # Methods for Light Modes #
    ###########################
    def default
      rt = nil
      dt = Thread.new do
        loop do
          if Time.now.hour.between?(START_TIME, STOP_TIME)
            if rt.nil?
              rt = round_trip(Color.new(red: 165, green: 133, blue: 155))
            end
          else
            unless rt.nil?
              rt.kill
              rt = nil
            end
            clear_lights()
            sleep(5)
          end
        end
      end
      @animation_threads.push(dt)
      dt
    end

    # Go up and down the row with a color
    def round_trip(color = nil, rate = 0.1, looped = true)
      counter = 0
      increasing = true
      rt = Thread.new do 
        loop do
          break unless looped
          clear_lights() if @clear
          unless @color.nil?
            color ||= Color.new(red: @color["red"], 
                                blue: @color["blue"], 
                                green: @color["green"])
          end
          @lights_array.each_with_index do |light, i|
            if counter == i or counter == i - 1
              light.color = color
            else
              light.color = Color.off
            end
          end
          increasing ? counter += 2 : counter -= 2
          if counter > NUM_OF_LIGHTS - 1 and increasing
            counter = NUM_OF_LIGHTS - 1
            increasing = false
          end
          if counter < 0 and !increasing
            counter = 0
            increasing = true
          end
          # Write to LED strip
          msg = led_message()
          PiPiper::Spi.begin do
              write((msg))
          end
          sleep(rate)
        end
      end
      @animation_threads.push(rt)
      rt
    end

    def single_trip
    end

    def incremental
    end

    def fluctuate
    end

    def fill(color = nil)
      clear_lights() if @clear
      unless @color.nil?
        color ||= Color.new(red: @color["red"], 
                            blue: @color["blue"], 
                            green: @color["green"])
      end
      @lights_array.each do |light|
        light.color = color
      end
      # Write to LED strip
      msg = led_message()
      PiPiper::Spi.begin do
          write((msg))
      end
    end

    def custom
      clear_lights() if @clear
      @colors.each_with_index do |raw_color, i|
        red = raw_color["red"] || 128
        blue = raw_color["blue"] || 128
        green = raw_color["green"] || 128
        color = Color.new(red: red, blue: blue, green: green)
        if i < NUM_OF_LIGHTS - 1
          @lights_array[i].color = color
        end
      end
      msg = led_message()
      PiPiper::Spi.begin do
        write(msg)
      end
    end

    def clear_lights
      @lights_array.each do |light|
        light.color = Color.new(red: 128, blue: 128, green: 128)
      end
      msg = led_message()
      PiPiper::Spi.begin do
        write(msg)
      end
    end

    private

    def parse_request(instructions)
      unless @animation_threads.empty?
        @animation_threads.each { |t| t.kill }
        @animation_threads = []
      end
      @setup = instructions["setup"] || @setup
      @mode = @setup["mode"] || @mode
      clear_lights() if @mode == "off"
      @clear = @setup["clear"] || @clear
      @colors = instructions["colors"] || @colors
      @color = instructions["color"] || @color
    end

  end
end
