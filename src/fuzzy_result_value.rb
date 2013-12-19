class FuzzyResultValue
  def number
    @number.respond_to?(:number) ? @number.number : @number
  end
  def reason
    @reason
  end

  def reason= value
    unless value.respond_to? :each
      value = [value]
    end
    value.each do |v|
      @reason << v
    end
  end

  def initialize value, reason
    @number = value
    @reason = [reason]
  end
  def method_missing(name, *args, &blk)
    ret = @number.send(name, *args, &blk)
    ret.is_a?(Numeric) ? FuzzyResultValue.new(ret, @reason) : ret
  end

  def to_s
    @number.to_s
  end

  def == object
    @number == object
  end
end