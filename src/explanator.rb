# encoding: utf-8
require_relative 'rule'
class Explanator
  attr_accessor :tab_step
  def self.explain result, table
    new(table).send(:ex, result)
  end

  def self.explain_in_text result, table, tab_step = '    '
    return tr 'Nothing satisfies the criteria' if result.nil?
    explanator = new(table)
    explanator.tab_step = tab_step
    explanator.send(:ex_text, result, '')
  end

  private
  def initialize table
    @table=table
  end

  def ex result
    if result.class==ResultValue
      [result, ex(result.reason)]
    elsif result.class==Rule
      exp = []
      result.conjuncts.each_pair do |key, value|
        exp << [key, ex(@table[key])]
      end
      [result, exp]
    else
      result
    end
  end

  def ex_text result, tab=''
    if result.class==ResultValue
      result + " #{tr 'because'}\n"+ ex_text(result.reason, tab+@tab_step)
    elsif result.class==Rule
      exp = "\n"
      result.conjuncts.each_key do |key|
        exp += tab+key + " " +ex_text(@table[key], tab+@tab_step)
      end
      tab+result.to_s+exp
    else
      tab+"#{tr 'It is user input'}\n"
    end
  end

end