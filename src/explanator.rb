class Explanator
  def self.explain result, table
    new(table).send(:ex, result)
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
        exp << [key, ex(@table[value])]
      end
      [result, exp]
    else
      result
    end
  end

end