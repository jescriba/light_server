# Wrapper for creating JSON message for light server
# message can get sent through client
class Message
  attr_reader :cmd_hash, :status, :mode

  def initialize
    @cmd_hash = {}
  end

  def status=(status)
    @status = status
    @cmd_hash[:status] = status
  end

  def mode=(mode)
    @mode = mode
    @cmd_hash[:mode] = mode
  end

end
