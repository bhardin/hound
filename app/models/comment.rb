class Comment
  attr_accessor :line, :messages, :path, :position

  def initialize(attributes)
    @line = attributes[:line]
    @messages = attributes[:messages]
    @path = attributes[:path]
    @position = attributes[:position]
  end
end
