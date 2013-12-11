require_relative 'fuzzy_result_value'
class FuzzyFactTable# < Hash
  attr_accessor :source
  attr_accessor :algebra
  attr_accessor :current_rule
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
    new_value = algebra_calculate value, old_value
    if old_value.respond_to? :reason
      new_value.reason=old_value.reason
    end
    raise MoreThanOneException.new if new_value > 1
    @props[property][key]=new_value
    @changed = true unless (value==0)
  end

  def algebra_calculate(value, old_value)
    result=nil
    old_value||= 0
    @algebra||='sum'
    case @algebra
      when 'sum' then begin
        result = value + old_value
      end
      when 'am' then begin
        result = my_max(value, old_value)
      end
      when 'ap' then begin
        result = value + old_value - (value*old_value).fdiv(2)
      end
      else
        raise Exception.new 'Unknown algebra: '+@algebra
    end
    result
  end

  def my_max(v1, v2)
    v1 > v2 ? v1 : v2
  end

  def [](property, key=nil)
    property = property.to_s
    @props[property]||=lambda{
      from_source = @source.ask strip_special_from(property), @current_rule
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

  def strip_special_from property
    property.gsub /@.*@/, ''
  end

  class EmptySource
    def ask prop, rule=nil
      nil
    end
  end

  class MoreThanOneException < Exception
  end

end