## Handles the SPI and Row Status
#
require 'pi_piper'
require_relative 'light.rb'

module Lights
  class RowHandler
    include PiPiper
    attr_reader :light_array, :command_history
   
    NUM_OF_LEDS = 32
    @@modes = [:default, :fill, :fluctuate]
    
    def initialize
      @light_array = []
      @command_history = []
      NUM_OF_LEDS.times do |i|
        @light_array.push(Light.new(status = false))
      end
      # Initialize quick light up for visual inspection
      setup_test()
    end

    def update(instructions)
      @command_history.push([Time.now, instructions])
      @command_history.shift(30) if @command_history.size > 300
      mode = instructions[mode]
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
      sleep(1)
      fill(Color.new(red: 128, green: 128, blue: 128))
    end

    ## Uses the light array configurations to construct the byte message
    # to send to spi device
    def led_message()
      
    end

    ## Methods for modes
    #
    #
    def default
      fill(Color.new(red: 140, green: 140, blue: 140))
    end

    def fill(color)
      msg = Array.new(32, [color.green, color.red, color.blue])
      msg.unshift(0, 0, 0)
      msg.flatten
      PiPiper::Spi.begin do
        puts write(msg)
      end
      ## PiPiper::Spi.begin do
      #    puts write(led_message())
      #  end
    end

    def fluctuate
    end

    def custom
    end

  end
end
