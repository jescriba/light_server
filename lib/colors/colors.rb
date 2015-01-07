module Colors
  ## Consider using colorist or some color gem
  class Color
    attr_reader :red, :green, :blue

    def initialize(opts = {})
      @red, @green, @blue = opts[:red], opts[:green], opts[:blue]
    end

    def normalize
      [@red, @green, @blue].each do |color|
        if color.nil?
          color = 128
        elsif !color.between?(128, 256)
          color = 128
        end
      end
    end

    # Creates array of bytes that represent acceptable grb on the LED strip
    # yes - grb.
    def convert_to_led_msg
      normalize()
      [@green, @red, @blue]
    end
  end
end
