## Consider using colorist or some color gem
module Colors
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

    def self.off
      Color.new(red: 128, green: 128, blue: 128)
    end
  end
end
