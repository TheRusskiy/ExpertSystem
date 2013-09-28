require_relative 'test_helper'

class TestExplanator < MiniTest::Unit::TestCase
  FakeSource = Class.new do
    attr_writer :value
    def ask(key)
      if @value.is_a? Proc
        @value.call key
      else
        @value
      end
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
    @fake_source.value= lambda{ |key|
      return '4' if key==:'2x2=?'
      nil
    }
    @system.goal = :'Am I smart?'
    rule=Rule.new({:'2x2=?' => '4'}, :'Am I smart?' => 'yes')
    @system.add rule
    explanation = Explanator.explain @system.result, @table
    # that's freaking complicated!
    # Scheme is: [answer, [why answer?]]
    # if answer == rule then explanation is: [why conjunct 1?] {,[why conjunct n?]}
    assert explanation == ['yes', [rule, [[:'2x2=?', ['4', :input]]]]]
  end

  def test_explanation_text
    @fake_source.value= lambda{ |key|
      #return 'autumn' if key==:'time of season is'
      return 'cloudy' if key==:'sky is'
      return 'falling' if key==:'leafs are'
      return 'cold' if key==:'weather is'
      nil
    }
    goal = :'it is going to'
    r1= Rule.new({:'time of season is' => 'autumn', :'sky is' => 'cloudy'},
                   goal  => 'rain')
    r2 = Rule.new({:'leafs are' => 'falling', :'weather is' => 'cold'},
                    :'time of season is' => 'autumn')
    @system.add r1, r2
    @system.goal=goal
    text =  Explanator.explain_in_text @system.result, @table
    explanation = "rain because\n" +
                  "If time of season is autumn and sky is cloudy then it is going to rain\n" +
                  "time of season is autumn because\n" +
                  "If leafs are falling and weather is cold then time of season is autumn\n" +
                  "leafs are falling because\n" +
                  "It is user input\n" +
                  "weather is cold because\n" +
                  "It is user input\n" +
                  "sky is cloudy because\n" +
                  "It is user input\n"
    assert_equal explanation, text
  end

end
      