require_relative 'test_helper'

class TestFuzzyExpertSystem < MiniTest::Unit::TestCase
  FakeSource = Class.new do
    attr_writer :value
    def ask(key)
      @value
    end
  end

  def setup
    @table = FuzzyFactTable.new
    #noinspection RubyArgCount
    @fake_source = FakeSource.new
    @table.source = @fake_source
    @system = FuzzyExpertSystem.new(@table)
    @table['p1', 'k1'] = 0.7
    @table['p1', 'k2'] = 0.3
    @table['p2', 'k1'] = 0.5
    @table['p2', 'k2'] = 0.5
    @table['p3', 'k1'] = 1
  end

  def teardown
    # Do nothing
  end

  def test_can_have_rules
    assert_equal @system.rules.length, 0
    r1 = FuzzyRule.new
    @system.add(r1)
    assert_equal @system.rules.length, 1
  end

  def test_can_reach_goal
    skip
    @system.goal = 'how to fly?'

    r1 = FuzzyRule.new({'key1'=> 'value1', 'key2'=> 'value2'},
                  'first_rule_result '=> 'first_rule_result')
    # depends on 'r1' to add property to the fact table
    r2 = Rule.new({'key3'=> 'value3', 'first_rule_result '=> 'first_rule_result'},
                  'how to fly?' => 'go out the window')

    @system.add r1, r2
    assert_equal 'go out the window', @system.result
  end

  def test_nil_if_cant_reach_goal
    skip
    @system.goal = 'how to fly?'
    r1 = Rule.new({'key1'=> 'value1', 'key2'=> 'value2'},
                  'first_rule_result '=> 'first_rule_result')
    r2 = Rule.new({'key3'=> 'WRONG', 'first_rule_result'=> 'first_rule_result'},
                  'how to fly?' => 'go out the window')

    @system.add r1, r2
    assert_nil @system.result
  end

  def test_raises
    skip
    assert_raises(ArgumentError) do
      # fact table = nil
      ExpertSystem.new nil
    end
    assert_raises(ExpertSystem::IncorrectStateException) do
      system = ExpertSystem.new({})
      # goal not specified
      system.result
    end
  end

  def test_count_of_activated_rules
    skip
    @system.goal = 'goal'
    r1 = Rule.new( {'key1' => 'value1'}, { 'key1_1' => 'value1_1'})
    r2 = Rule.new( {'key1_1' => 'value1_1'}, { 'key1_2' => 'value1_2'})
    r3 = Rule.new( {'key1_2' => 'value1_2'}, { 'goal' => 'goal_value'})
    @system.add r1, r2, r3
    @system.result
    assert_equal @system.rules_activated, 3
  end

  def test_count_of_activated_rules_on_failure
    skip
    @system.goal = 'goal'
    r1 = Rule.new( {'key1' => 'value1'}, { 'key1_1' => 'value1_1'})
    r2 = Rule.new( {'key1_1' => 'value1_1'}, { 'non_existent_key' => 'some_value'})
    r3 = Rule.new( {'no_such_key' => 'some_value'}, { 'some_key' => 'some_value'})
    @system.add r1, r2, r3
    @system.result
    assert_equal @system.rules_activated, 2
  end

end
      