class ResultValue < String
  attr_reader :reason
  def initialize value, reason
    super value
    @reason = reason
  end
end