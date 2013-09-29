class ExpertSystem
  attr_reader :rules
  attr_accessor :goal

  def initialize(fact_table)
    raise ArgumentError.new("Fact table can't be nil") if fact_table.nil?
    @fact_table = fact_table
    @rules=[]
  end

  def add(*rules)
    rules.each do |r|
      @rules << r
    end
  end

  def result
    start
    @fact_table[@goal]
  end

  class IncorrectStateException < Exception

  end

  private
  def start
    raise IncorrectStateException.new('Goal property has to be set') if @goal.nil?
    begin
      @fact_table.reset_changed
      @rules.each { |rule|
        rule.check @fact_table
      }
    end while @fact_table.changed?
  end

end