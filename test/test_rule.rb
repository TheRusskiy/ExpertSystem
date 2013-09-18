require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../src/rule'
MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new

class TestRule < MiniTest::Unit::TestCase
  def setup
    @fact_table = {}
    @rule = Rule.new(@fact_table)
  end

  def teardown
    # Do nothing
  end

  def test_new_conjuncts_can_be_added
    @rule.add('property', 'value')
    assert(@rule.conjuncts.length == 1)
  end

  def test_rule_can_be_true
    @rule.add('property', 'truthy_value')
    @fact_table['property']='truthy_value'
    assert(@rule.check)
  end

  def test_rule_can_be_false
    @rule.add('property', 'falsy_value')
    @fact_table['property']='truthy_value'
    refute(@rule.check)
  end

  def test_rule_fails_if_single_conjunct_is_false
    @rule.add('property_1', 'true')
    @fact_table['property_1']='true'
    @rule.add('property_2', 'false')
    @fact_table['property_2']='true'
    refute(@rule.check)
  end

end
      