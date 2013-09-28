require_relative 'test_helper'

class TestResultValue < MiniTest::Unit::TestCase
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  def test_result_value_acts_as_string
    rv = ResultValue.new 'value', nil
    assert rv == 'value'
  end

  def test_result_has_reason
    rule = Rule.new
    result = ResultValue.new 'value', rule
    assert_equal rule, result.reason
  end

  def test_reason_can_be_user_input
    fakeSource = Class.new do
      def ask(key)
        'some_value'
      end
    end
    #noinspection RubyArgCount
    table = FactTable.new fakeSource.new
    table['foo_key'] = 'foo_value'

    assert_equal table['non_present_key'].reason, :input
  end

end
      