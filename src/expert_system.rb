class ExpertSystem
  attr_reader :rules

  def initialize(fact_table)
    raise ArgumentError.new("Fact table can't be nil") if fact_table.nil?
    @fact_table = fact_table
    @rules=[]
    @computation_was_made=false
  end

  def add(*rules)
    rules.each do |r|
      @rules << r
    end
  end

  def goal=(goal)
    @goal=goal
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
    @computation_was_made=true
  end

end