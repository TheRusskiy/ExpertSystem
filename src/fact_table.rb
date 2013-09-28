class FactTable < Hash
  alias :super_accessor :[]
  attr_accessor :source
  def initialize(source=nil)
    @changed=false
    @source=source
  end

  def []=(key, value)
    old_value=super_accessor(key)
    super
    @changed = true unless old_value == value
  end

  def [](key)
    result = super
    if result.nil?
      from_source = @source.ask key
      self[key]= from_source.nil? ? nil : ResultValue.new(from_source, :input)
    end
    super
  end

  def changed?
    @changed
  end

  def reset_changed
    @changed=false
  end


end