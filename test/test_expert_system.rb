require 'minitest/autorun'
require 'minitest/reporters'
require '../src/expert_system'
require '../src/rule'
require '../src/fact_table'
MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new

class TestExpertSystem < MiniTest::Unit::TestCase
  FakeSource = Class.new do
    def ask(key)
      nil
    end
  end

  def setup
    @table = FactTable.new
    #noinspection RubyArgCount
    @table.source = FakeSource.new
    @system = ExpertSystem.new(@table)
    @table[:key1] = 'value1'
    @table[:key2] = 'value2'
    @table[:key3] = 'value3'
    @table[:key4] = 'value4'
  end

  def teardown
    # Do nothing
  end

  def test_can_have_rules
    assert_equal @system.rules.length, 0
    r1 = Rule.new
    @system.add(r1)
    assert_equal @system.rules.length, 1
  end

  def test_can_reach_goal
    @system.goal = 'how to fly?'

    r1 = Rule.new
    r1.add(:key1, 'value1')
    r1.add(:key2, 'value2')
    r1.add_result(:first_rule_result, 'first_rule_result')

    r2 = Rule.new
    r2.add(:key3, 'value3')
    r2.add(:first_rule_result, 'first_rule_result')
    # depends on 'r1' to add property to the fact table
    r2.add_result('how to fly?', 'go out the window')

    @system.add r1
    @system.add r2
    @system.start
    assert_equal 'go out the window', @system.result
  end

  def test_nil_if_cant_reach_goal
    @system.goal = 'how to fly?'

    r1 = Rule.new
    r1.add(:key1, 'value1')
    r1.add(:key2, 'value2')
    r1.add_result(:first_rule_result, 'first_rule_result')

    r2 = Rule.new
    r2.add(:key3, 'WRONG')
    r2.add(:first_rule_result, 'first_rule_result')
    # depends on 'r1' to add property to the fact table
    r2.add_result('how to fly?', 'go out the window')

    @system.add r1
    @system.add r2
    @system.start
    assert_nil @system.result
  end

  def test_raises
    skip 'todo'
    assert_raises(ExpertSystem::IncorrectSystemStateException) do

    end
  end


end
      