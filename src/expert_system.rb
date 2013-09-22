class ExpertSystem
  attr_reader :rules

  def initialize(fact_table)
    raise ArgumentError.new("Fact table can't be nil") if fact_table.nil?
    @fact_table = fact_table
    @rules=[]
    @computation_was_made=false
  end

  def add(rule)
    @rules << rule
  end

  def goal=(goal)
    @goal=goal
  end

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

  def result
    raise IncorrectStateException.new('Compute first') unless @computation_was_made
    @fact_table[@goal]
  end

  class IncorrectStateException < Exception

  end

end