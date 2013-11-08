require_relative 'test_helper'

class TestFuzzyExpertSystem < MiniTest::Unit::TestCase
  def setup
    @table = FuzzyFactTable.new
    @system = ExpertSystem.new(@table)
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
    @system.goal = 'how to fly?'

    @table['pr1', 'k1'] = 0.8
    r1 = FuzzyRule.new([['pr1', 'k1', 0.9]], # conjunct
                       [['pr2', 'k1', 0.9]]) # result
    # depends on 'r1' to add property to the fact table
    r2 = FuzzyRule.new([['pr2', 'k1', 0.9]], # conjunct
                  [['how to fly?','go out the window', 0.5], ['how to fly?', 'buy a jet', 0.6]]) # result

    @system.add r1, r2
    assert_equal @system.result.length, 2
    assert_in_delta @system.result['go out the window'], 0.8*0.9*0.9*0.9*0.5
    assert_in_delta @system.result['buy a jet'], 0.8*0.9*0.9*0.9*0.6
  end

  def test_nil_if_cant_reach_goal
    @system.goal = 'how to fly?'

    @table['pr1', 'k1'] = 0.8
    r1 = FuzzyRule.new([['pr1', 'k1', 0.9]], # conjunct
                       [['pr2', 'k1', 0.9]]) # result
    # depends on 'r1' to add property to the fact table
    r2 = FuzzyRule.new([['WRONG', 'k1', 0.9]], # << WRONG
                       [['how to fly?','go out the window', 0.5], ['how to fly?', 'buy a jet', 0.6]]) # result

    @system.add r1, r2
    assert_equal @system.result, nil
  end

  def test_raises
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
    @system.goal = 'how to fly?'

    @table['pr1', 'k1'] = 0.8
    r1 = FuzzyRule.new([['pr1', 'k1', 0.9]], # conjunct
                       [['pr2', 'k1', 0.9]]) # result
                                             # depends on 'r1' to add property to the fact table
    r2 = FuzzyRule.new([['pr2', 'k1', 0.9]], # conjunct
                       [['how to fly?','go out the window', 0.5], ['how to fly?', 'buy a jet', 0.6]]) # result

    @system.add r1, r2
    @system.result # calculate everything
    assert_equal @system.rules_activated, 2
  end

  def test_count_of_activated_rules_on_failure
    @system.goal = 'how to fly?'

    @table['pr1', 'k1'] = 0.8
    r1 = FuzzyRule.new([['pr1', 'k1', 0.9]], # conjunct
                       [['pr2', 'k1', 0.9]]) # result
                                             # depends on 'r1' to add property to the fact table
    r2 = FuzzyRule.new([['WRONG', 'k1', 0.9]], # << WRONG
                       [['how to fly?','go out the window', 0.5], ['how to fly?', 'buy a jet', 0.6]]) # result
    @system.add r1, r2
    @system.result # calculate everything
    assert_equal @system.rules_activated, 1
  end

end
      