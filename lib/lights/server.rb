require 'json'
require 'pi_piper'

module Lights
  class Server
    include PiPiper

    def initialize
      @row_handler = RowHandler.new
    end

    # Process JSON requests from web server
    def listen(data)
      ## TODO: Check if needs to be updated by comparing to command history
      data_table = JSON.parse(data)
      update(data_table) # For now just calling update regardless
    end

    # Updates SPI status
    def update(instructions)
      @row_handler.update(instructions)
    end
  end
end
