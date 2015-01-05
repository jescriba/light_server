# Require colors

module Lights
  class Light
    attr_reader :status, :color, :history
  
    # Light has a status - bool for on or off and a Color
    def initialize(status = nil, color = nil)
      @status = status
      @color = color
      @history = []
    end

    def status=(status)
      raise TypeError unless status.is_a?(TrueClass)
      @status = status
      @history.push([Time.now, status])
      trim(@history)
      ## TODO: Maybe add way to store history in db
      # for the times I may restart the server
    end

    def color=(color)
      raise TypeError unless color.is_a?(Color)
      @color = color
      @history.push([Time.now, color])
      trim(@history)
    end

    def trim(history)
      history.shift(50) if history.size > 3000 
    end

  end
end
