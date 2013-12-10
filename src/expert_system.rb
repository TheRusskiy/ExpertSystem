class ExpertSystem
  attr_reader :rules
  attr_accessor :goal

  def initialize(fact_table)
    raise ArgumentError.new("Fact table can't be nil") if fact_table.nil?
    @fact_table = fact_table
    @rules=[]
  end

  def add(*rules)
    rules.flatten!
    rules.each do |r|
      @rules << r
    end
  end

  def result
    start
    @fact_table[@goal]
  end

  def rules_activated
    @rules_activated
  end

  class IncorrectStateException < Exception

  end

  private
  def start
    raise IncorrectStateException.new('Goal property has to be set') if @goal.nil?
    @rules_activated=0
    begin
      new_rules = Array.new(@rules)
      @fact_table.reset_changed
      @rules.each { |rule|
        if rule.check @fact_table
          @rules_activated+=1
          new_rules.delete rule
        end
      }
      @rules = new_rules
    end while @fact_table.changed?
  end

end