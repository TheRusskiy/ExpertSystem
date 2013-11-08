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
    @rule.add('property', 'key', 1)
    assert(@rule.conjuncts.length == 1)
  end

  def test_rule_adds_results
    @rule.add('property', 'key', 0.6)
    @rule.add_result('result_property', 'result_key', 0.7)
    @fact_table['property', 'key']=0.8
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0.336
  end

  def test_rule_cuts_off_results
    @rule.add('property', 'key', 0.5)
    @rule.add_result('result_property', 'result_key', 0.5)
    @fact_table['property', 'key']=0.5
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0
  end

  def test_rule_stops_calculating_preemptively
    @rule.add('property1', 'key', 0.5)
    @rule.add('property2', 'key', 0.5)
    @rule.add_result('result_property', 'result_key', 0.5)
    @fact_table.source = Mock.new :ask, lambda{ |property|
      if @already_called
        raise Exception.new "Calculation should have stopped once it knew it can't succeed"
      end
      @already_called = true
      return {'key' => 0.3}
    }
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0
  end

  def test_rule_calculates_once
    @rule.add('property', 'key', 1)
    @rule.add_result('result_property', 'result_key', 0.8)
    @fact_table['property', 'key']=0.6
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0.48
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property', 'result_key'], 0.48
  end

  def test_can_have_multiple_results
    @rule.add('property', 'key', 1)
    @rule.add_result('result_property_1', 'result_key_1', 0.8)
    @rule.add_result('result_property_1', 'result_key_2', 0.6)
    @rule.add_result('result_property_2', 'result_key_3', 0.9)
    @fact_table['property', 'key']=0.5
    @rule.calculate(@fact_table)
    assert_in_delta @fact_table['result_property_1', 'result_key_1'], 0.4
    assert_in_delta @fact_table['result_property_1', 'result_key_2'], 0.3
    assert_in_delta @fact_table['result_property_2', 'result_key_3'], 0.45
  end

  def test_constructor_takes_bulk_params
    conjuncts = [['k1', 'v1', 0.9], ['k2', 'v2', 0.9]]
    results = [['k3', 'v3', 0.5], ['k4', 'v4', 0.6]]
    rule = FuzzyRule.new(conjuncts, results)

    conjuncts.each do |r|
      @fact_table[r[0], r[1]]=0.8
    end

    rule.calculate @fact_table
    assert_equal rule.conjuncts, conjuncts

    results.each_with_index do |r, i|
      assert_in_delta @fact_table[r[0]][r[1]], results[i][2]*0.8*0.8*0.9*0.9
    end
  end

end
      