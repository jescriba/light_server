require 'json'
require 'pi_piper'

module Lights
  NUM_OF_LEDS = 32

  class Server
    include PiPiper

    def initialize
      # Launching the Server flashes the LEDs
      PiPiper::Spi.begin do
        on = Array.new(3 * NUM_OF_LEDS, 0xff)  
        on.push(0, 0, 0)
        off = Array.new(3 * NUM_OF_LEDS, 0x80)
        off.push(0, 0, 0)
        write(on)
        sleep(0.5)
        write(off)
      end
    end

    # Process JSON requests from web server
    def listen(data)

    end

    # Receives requests and then checks if the 
    # lights actually need to be updated by referencing
    # current status
    def update(instructions)
      # Updates SPI status
      RowHandler.check_for_update(instructions)
    end

  end
end
