class FuzzyRule
  attr_reader :conjuncts
  def initialize(conjuncts = [], results = [])
    $cutoff||=0.2 # Kids who use globals are in Santa's naughty list
    @conjuncts = conjuncts
    @results = results # [property, key, value]
    @is_rule_true = false
  end

  def add(property, key, probability)
    check_state
    @conjuncts << [property, key, probability]
  end

  def add_result(property_if_true, key_if_true, value_to_add)
    check_state
    @results << [property_if_true, key_if_true, value_to_add]
  end

  def check(fact_table)
    return @is_rule_true if @calculated
    result = 1
    @conjuncts.each do |c|
      if result < $cutoff # don't ask user if there's no chance to go over $cutoff
        result = 0
        break
      end
      fact_table.current_rule = self
      return @is_rule_true unless fact_table[c[0]]
      result*=(fact_table[c[0], c[1]]*c[2]) # if it is nil then you've messed up => exception is ok
    end

    #result = 0 if result < $cutoff

    @results.each do |r|
      new_value = r[2]*result
      next if new_value < $cutoff
      fact_table[r[0], r[1]]=FuzzyResultValue.new(new_value, self)
    end

    @calculated = true
    @is_rule_true = true
    @is_rule_true
  end

  def to_s fold_lines = false
    new_line = fold_lines ? "<br/>" : ''
    text = tr 'If'
    text += ' '
    text += array_to_text @conjuncts, new_line
    text += " #{tr 'then'} "+new_line
    text += array_to_text @results, new_line
    text.gsub(/@.*@/, '')
  end

  #def array_to_text array
  #  text = ''
  #  separator = " #{tr 'and'} "
  #  i=1
  #  array.each_pair do |key, value|
  #    text+=key.to_s+' '+value.to_s
  #    text+= separator if i!=array.length
  #    i+=1
  #  end
  #  text
  #end

  def array_to_text array, new_line = ''
    text = ''
    separator = " #{tr 'and'} "+new_line
    i=1
    array.each do |r|
      text+=r[0].to_s+': '+r[1].to_s+" (x#{r[2]*100})"
      text+= separator if i!=array.length
      i+=1
    end
    text
  end

  def check_state
    raise Exception.new "Rule can't be changed after if was calculated" if @calculated
  end

end