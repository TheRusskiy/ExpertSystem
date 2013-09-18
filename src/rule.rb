class Rule
  attr_reader :conjuncts
  def initialize(fact_table)
    @fact_table=fact_table
    @conjuncts = {}
  end

  def add(variable, truthy_value)
    @conjuncts[variable] = truthy_value
  end

  def check
    @conjuncts.each_pair do |property, value|
      if @fact_table[property]!=value
        return false
      end
    end
    true
  end

end