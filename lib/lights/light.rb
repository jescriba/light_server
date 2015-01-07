# Require colors
require_relative '../colors/colors.rb'

module Lights
  class Light
    include Colors
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
      @history.shift(50) if history.size > 300
    end

    def color=(color)
      raise TypeError unless color.is_a?(Color)
      @color = color
      @history.push([Time.now, color])
      trim(@history)
      @history.shift(50) if history.size > 300
    end
  end
end
