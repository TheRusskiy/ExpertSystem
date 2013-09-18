class FactTable < Hash
  attr_accessor :source
  def initialize
    #super
  end

  def []=(key, value)
    super
  end

  def [](key)
    result = super
    if super.nil?
      self[key]=@source.ask(key)
    end
    result
  end


end