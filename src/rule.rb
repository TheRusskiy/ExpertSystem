class Rule
  attr_reader :conjuncts
  def initialize(conjuncts = {}, results = {})
    @conjuncts = conjuncts
    @results = results
  end

  def add(variable, truthy_value)
    @conjuncts[variable] = truthy_value
  end

  def add_result(key_if_true, value_if_true)
    @results[key_if_true]=value_if_true
  end

  def check(fact_table)
    @conjuncts.each_pair do |property, value|
      if fact_table[property]!=value
        return false
      end
    end

    @results.each_pair do |property, value|
      fact_table[property]=ResultValue.new(value, self)
    end

    true
  end

  def to_s
    text = tr 'If'
    text += ' '
    text += hash_to_text conjuncts
    text += " #{tr 'then'} "
    text += hash_to_text @results
    text
  end

  def hash_to_text hash
    text = ''
    separator = " #{tr 'and'} "
    i=1
    hash.each_pair do |key, value|
      text+=key.to_s+' '+value.to_s
      text+= separator if i!=hash.length
      i+=1
    end
    text
  end

end