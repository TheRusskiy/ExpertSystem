class FactTable < Hash
  alias :super_accessor :[]
  attr_accessor :source
  def initialize
    @changed=false
  end

  def []=(key, value)
    old_value=super_accessor(key)
    super
    @changed = true unless old_value == value
  end

  def [](key)
    result = super
    if super.nil?
      self[key]=@source.ask(key)
    end
    result
  end

  def changed?
    @changed
  end

  def reset_changed
    @changed=false
  end


end