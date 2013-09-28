require_relative 'test_helper'

class TestExplanator < MiniTest::Unit::TestCase
  FakeSource = Class.new do
    attr_writer :value
    def ask(key)
      @value
    end
  end

  def setup
    @table = FactTable.new
    #noinspection RubyArgCount
    @fake_source = FakeSource.new
    @table.source = @fake_source
    @system = ExpertSystem.new(@table)
  end

  def teardown
    # Do nothing
  end

  def test_explains_user_input
    @fake_source.value='4'
    @system.goal = :'Am I smart?'
    rule=Rule.new({:'2x2=?' => '4'}, :'Am I smart?' => 'yes')
    @system.add rule
    explanation = Explanator.explain @system.result, @table
    # that's freaking complicated!
    # Scheme is: [answer, [why answer?]]
    # if answer == rule then explanation is: [why conjunct 1?] {,[why conjunct n?]}
    assert explanation == ['yes', [rule, [[:'2x2=?', ['4', :input]]]]]
  end

end
      