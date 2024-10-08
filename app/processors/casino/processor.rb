class CASino::Processor
  attr_reader :listener
  def initialize(listener)
    @listener = listener
  end
end
