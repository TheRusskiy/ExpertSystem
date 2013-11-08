class FuzzyRule
  attr_reader :conjuncts
  def initialize(conjuncts = {}, results = [])
    $cutoff||=0.2 # Kids who use globals are in Santa's naughty list
    @conjuncts = conjuncts # [property, key, value]
    @results = results
  end

  def add(variable, truthy_value)
    check_state
    @conjuncts[variable] = truthy_value
  end

  def add_result(property_if_true, key_if_true, value_to_add)
    check_state
    @results << [property_if_true, key_if_true, value_to_add]
  end

  def calculate(fact_table)
    return if @calculated
    result = 1
    @conjuncts.each do |c|
      return unless fact_table[c[0]]
      result*=fact_table[c[0], c[1]] # if it is nil then you've messed up => exception is ok
    end

    #result = 0 if result < $cutoff
    @results.each do |r|
      fact_table[r[0], r[1]]=r[2]*result
    end

    @calculated = true
  end

  def to_s
    text = tr 'If'
    text += ' '
    text += hash_to_text conjuncts
    text += " #{tr 'then'} "
    text += results_to_text @results
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

  def results_to_text results
    text = ''
    separator = " #{tr 'and'} "
    i=1
    results.each do |r|
      text+=r[0].to_s+' '+r[1].to_s+" #{tr 'with probability'} #{r[2]}"
      text+= separator if i!=results.length
      i+=1
    end
    text
  end

  def check_state
    raise Exception.new "Rule can't be changed after if was calculated" if @calculated
  end

end