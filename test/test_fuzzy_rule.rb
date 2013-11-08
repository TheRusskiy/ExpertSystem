require_relative 'test_helper'

class TestFuzzyRule < MiniTest::Unit::TestCase
  def setup
    @fact_table = FuzzyFactTable.new
    @rule = FuzzyRule.new
  end

  def teardown
    # Do nothing
  end

  def test_new_conjuncts_can_be_added
    assert(@rule.conjuncts.length == 0)
    @rule.add('property', 'key')
    assert(@rule.conjuncts.length == 1)
  end

  def test_rule_adds_results
    @rule.add('property', 'key')
    @rule.add_result('result_property', 'result_key', 0.8)
    @fact_table['property', 'key']=0.6
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0.48
  end

  def test_rule_cuts_off_results
    skip 'When should we cut off? Only final results or on every step?'
    @rule.add('property', 'key')
    @rule.add_result('result_property', 'result_key', 0.8)
    @fact_table['property', 'key']=0.1
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0
  end

  def test_rule_calculates_once
    @rule.add('property', 'key')
    @rule.add_result('result_property', 'result_key', 0.8)
    @fact_table['property', 'key']=0.6
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0.48
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0.48
  end

  def test_can_have_multiple_results
    @rule.add('property', 'key')
    @rule.add_result('result_property_1', 'result_key_1', 0.8)
    @rule.add_result('result_property_1', 'result_key_2', 0.6)
    @rule.add_result('result_property_2', 'result_key_3', 0.9)
    @fact_table['property', 'key']=0.5
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property_1', 'result_key_1'], 0.4
    assert_in_delta @fact_table['result_property_1', 'result_key_2'], 0.3
    assert_in_delta @fact_table['result_property_2', 'result_key_3'], 0.45
  end

  def test_constructor_takes_hashes
    skip 'todo'
    conjuncts = {'k1' => 'v1', 'k2' => 'v2'}
    results = [['k3', 'v3', 0.5], ['k4', 'v4', 0.6]]
    rule = FuzzyRule.new(conjuncts, results)
    fact_table = {}.merge conjuncts

    rule.calculate fact_table
    assert_equal rule.conjuncts, conjuncts

    results.each_pair do |k, v|
      assert_equal fact_table[k], v
    end
  end

end
      