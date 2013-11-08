require_relative 'fuzzy_result_value'
class FuzzyFactTable# < Hash
  attr_accessor :source
  def initialize(source=EmptySource.new)
    @changed=false
    @source=source
    @props = Hash.new
  end

  def []=(property, key, value)
    property = property.to_s
    key = key.to_s
    @props[property]||=Hash.new
    old_value=@props[property][key]
    new_value = value + (old_value || 0)
    raise MoreThanOneException.new if new_value > 1
    @props[property][key]=new_value
    @changed = true unless (old_value == value)
  end

  def [](property, key=nil)
    property = property.to_s
    @props[property]||=lambda{
      from_source = @source.ask(property)
      unless from_source.nil?
        from_source.each_pair do |k, value|
          from_source[k] = FuzzyResultValue.new(value, :input)
        end
      end
      from_source
    }.call
    return @props[property] if key.nil?
    key = key.to_s
    @props[property].nil? ? nil : @props[property][key]
  end

  def changed?
    @changed
  end

  def reset_changed
    @changed=false
  end

  class EmptySource
    def ask prop
      nil
    end
  end

  class MoreThanOneException < Exception
  end

end