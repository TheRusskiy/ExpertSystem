# encoding: utf-8
require_relative 'rule'
class FuzzyExplanator
  attr_accessor :tab_step
  def self.explain result, table
    results = []
    if result.respond_to? :key
      result.each_pair do |key, value|
        results<<[key, new(table).send(:ex, value)]
      end
    end
    results
  end

  def self.explain_in_text result, table, tab_step = '    '
    return tr 'Nothing satisfies the criteria' if result.nil?
    explanator = new(table)
    explanator.tab_step = tab_step
    #explanator.send(:ex_text, result, '')
    results = []
    if result.respond_to? :key
      result.each_pair do |key, value|
        results<<key+" #{tr 'with probability'} "+ new(table).send(:ex_text, value, '').gsub(/@.*@/, '') unless value == 0
      end
    end
    results
  end

  private
  def initialize table
    @tab_step='  '
    @table=table
  end

  def ex result
    if result.class==FuzzyResultValue
      [result, ex(result.reason)]
    elsif result.class==FuzzyRule
      exp = []
      result.conjuncts.each do |arr|
        prop = arr[0]; key = arr[1]; value = arr[2]
        exp << [[prop, value], ex(@table[key])]
      end
      [result, exp]
    else
      input = []
      result.each_pair do |k, v|
        input<<[k, v, v.reason]
      end
      input
    end
  end

  def ex_text result, tab=''
    if result.class==FuzzyResultValue
      (result*100).round(0).to_s + " #{tr 'because'}\n"+ exp(result.reason, tab+@tab_step)
    elsif result.class==FuzzyRule
      exp = "\n"
      result.conjuncts.each do |arr|
        prop = arr[0]; key = arr[1]; value = arr[2]
        exp += tab+"#{key} #{ex_text(@table[prop, key].round(2), tab+@tab_step)}"
      end
      tab+result.to_s+exp
    else
      tab+"#{tr 'It is user input'}\n"
    end
  end

  def exp reason, some_shit
    result = ""
    reason.each do |r|
      result+=ex_text r, some_shit
    end
    result
  end

end