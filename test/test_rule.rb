require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../src/rule'
require_relative '../src/fact_table'
MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new

class TestRule < MiniTest::Unit::TestCase
  def setup
    @fact_table = FactTable.new
    @rule = Rule.new
  end

  def teardown
    # Do nothing
  end

  def test_new_conjuncts_can_be_added
    @rule.add(:property, 'value')
    assert(@rule.conjuncts.length == 1)
  end

  def test_rule_can_be_true
    @rule.add(:property, 'truthy_value')
    @fact_table[:property]='truthy_value'
    assert(@rule.check(@fact_table))
  end

  def test_rule_can_be_false
    @rule.add(:property, 'falsy_value')
    @fact_table[:property]='truthy_value'
    refute(@rule.check(@fact_table))
  end

  def test_rule_fails_if_single_conjunct_is_false
    @rule.add(:property_1, 'true')
    @fact_table[:property_1]='true'
    @rule.add(:property_2, 'false')
    @fact_table[:property_2]='true'
    refute(@rule.check(@fact_table))
  end

  def test_can_have_multiple_results
    @rule.add(:property, 'true')
    @fact_table[:property]='true'
    @rule.add_result(:property_1, 'value1')
    @rule.add_result(:property_2, 'value2')
    @rule.check @fact_table
    assert_equal(@fact_table[:property_1], 'value1')
    assert_equal(@fact_table[:property_2], 'value2')
  end

  def test_can_insert_result_into_table
    @rule.add :property, 'true'
    @fact_table[:property]='true'
    fake_source = Class.new do
      def ask(key)
        nil
      end
    end
    #noinspection RubyArgCount
    @fact_table.source = fake_source.new
    assert_nil(@fact_table[:if_true_property])

    @rule.add_result :if_true_property, 'new_fact_in_table'
    @rule.check @fact_table

    assert_equal @fact_table[:if_true_property], 'new_fact_in_table'
  end

  def test_constructor_takes_hashes
    conjuntcts = {'k1' => 'v1', 'k2' => 'v2'}
    results = {'k3' => 'v3', 'k4' => 'v4'}
    rule = Rule.new(conjuntcts, results)
    fact_table = {}.merge conjuntcts

    rule.check fact_table
    assert_equal rule.conjuncts, conjuntcts

    results.each_pair do |k, v|
      assert_equal fact_table[k], v
    end
  end

end
      