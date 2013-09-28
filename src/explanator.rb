# encoding: utf-8
class Explanator
  def self.explain result, table
    new(table).send(:ex, result)
  end

  def self.explain_in_text result, table
    new(table).send(:ex_text, result)
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

  def ex_text result
    if result.class==ResultValue
      result + " #{tr 'because'}\n"+ ex_text(result.reason)
    elsif result.class==Rule
      exp = "\n"
      result.conjuncts.each_pair do |key, value|
        exp += key + " " +ex_text(@table[key])
      end
      result.to_s+exp
    else
      "#{tr 'It is user input'}\n"
    end
  end

end