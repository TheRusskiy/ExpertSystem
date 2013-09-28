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
      result.to_s + " because\n"+ ex_text(result.reason).to_s
    elsif result.class==Rule
      exp = "\n"
      result.conjuncts.each_pair do |key, value|
        exp += key.to_s + " " +ex_text(@table[key]).to_s
      end
      result.to_s+exp.to_s
    else
      "It is user input\n"
    end
  end

end