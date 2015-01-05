## Handles the SPI and Row Status
#
require 'pi_piper'

module Lights
  class RowHandler
    include PiPiper

    NUM_OF_LEDS = 32
    attr_reader :light_array
    
    def initialize
      @light_array = []
      NUM_OF_LEDS.times do |i|
        @light_array.push(Light.new(status = false))
      end 
    end

    def update

    end

    ## Record of what the current json 
    # status of what the lights configuration is
    def status

    end

    ## Shuffle colors and fill them to row
    def setup_test
      msg = Array.new(32, 0x80)
      # Forgot if I want to be using unshift or push here
      msg.unshift(0, 0, 0)
      PiPiper::Spi.begin do
        write(msg)
      end
    end

  end
end
