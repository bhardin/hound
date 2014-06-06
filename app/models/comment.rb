class Comment
  attr_accessor :line

  def initialize(attributes)
    @line = attributes[:line]
  end
end
