class FuzzyResultValue
  attr_reader :reason
  def initialize value, reason
    @number = value
    @reason = reason
  end
  def method_missing(name, *args, &blk)
    ret = @number.send(name, *args, &blk)
    ret.is_a?(Numeric) ? FuzzyResultValue.new(ret, @reason) : ret
  end
end