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
    #@key_if_true = key_if_true
    #@value_if_true = value_if_true
  end

  def check(fact_table)
    @conjuncts.each_pair do |property, value|
      if fact_table[property]!=value
        return false
      end
    end

    @results.each_pair do |property, value|
      fact_table[property]=value
    end

    true
  end

end