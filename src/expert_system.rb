class ExpertSystem
  attr_reader :rules

  def initialize(fact_table)
    @fact_table = fact_table
    @rules=[]
  end

  def add(rule)
    @rules << rule
  end

  def goal=(goal)
    @goal=goal
  end

  def start
    begin
      @fact_table.reset_changed
      @rules.each { |rule|
        rule.check @fact_table
      }
    end while @fact_table.changed?
  end

  def result
    @fact_table[@goal]
  end

  #raise ExpertSystem::IncorrectSystemStateException
  class IncorrectSystemStateException < Exception

  end

end