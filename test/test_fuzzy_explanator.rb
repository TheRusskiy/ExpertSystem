# encoding: UTF-8
require_relative 'test_helper'

class TestFuzzyExplanator < MiniTest::Unit::TestCase
  def setup
    @table = FuzzyFactTable.new
    @system = ExpertSystem.new(@table)
  end

  def teardown
    # Do nothing
  end

  def test_explains_user_input
    @table.source = Mock.new :ask, lambda { |p|
      return {'4'=>1}
    }
    @system.goal = 'Am I smart?'
    rule=FuzzyRule.new([['2x2=?', '4', 1]],
                       [['Am I smart?', 'yes', 0.5]])
    @system.add rule
    explanation = FuzzyExplanator.explain @system.result, @table

    # ____  _____            _____ _   _ ______   ________   _______  _      ____  _____  ______ _ _ _
    #|  _ \|  __ \     /\   |_   _| \ | |___  /  |  ____\ \ / /  __ \| |    / __ \|  __ \|  ____| | | |
    #| |_) | |__) |   /  \    | | |  \| |  / /   | |__   \ V /| |__) | |   | |  | | |  | | |__  | | | |
    #|  _ <|  _  /   / /\ \   | | | . ` | / /    |  __|   > < |  ___/| |   | |  | | |  | |  __| | | | |
    #| |_) | | \ \  / ____ \ _| |_| |\  |/ /__   | |____ / . \| |    | |___| |__| | |__| | |____|_|_|_|
    #|____/|_|  \_\/_/    \_\_____|_| \_/_____|  |______/_/ \_\_|    |______\____/|_____/|______(_|_|_)


    # I WAS CRYING LIKE A BABY WRITING THIS!!!!!!!!!!!!!!
    # Fuck this test I have no use for it anyway
    assert_equal explanation, [
        ['yes',
         [0.5, [rule,[
                  [
                    ['2x2=?', 1], [['4', 1, :input]]
                  ]
                  # , second conjunct would go here
                ]
          ]
         ]
        ]
    ]
  end

  def test_explanation_text
    #test is britleeeeeee
    @table.source = Mock.new :ask, lambda{ |key|
      return {'cloudy' => 0.7, 'windy' => 0.3} if key=='sky is'
      return {'falling' => 0.6, 'in place' => 0.4} if key=='leafs are'
      return {'cold' => 1} if key=='weather is'
      nil
    }
    goal = 'it is going to'
    r1 = FuzzyRule.new([['time of season is','autumn', 1], ['sky is', 'cloudy', 1]],
                      [[goal, 'rain', 0.4], [goal, 'storm', 0.6]])
    r2 = FuzzyRule.new([['leafs are', 'falling', 1], ['weather is', 'cold', 1]],
                    [['time of season is', 'autumn', 1]])
    @system.add r1, r2
    @system.goal=goal
    text =  FuzzyExplanator.explain_in_text @system.result, @table, ''
    explanation =
        ["storm with probability 0.25 because\n"+
        "  If time of season is: autumn (x1) and sky is: cloudy (x1) then it is going to: rain (x0.4) and it is going to: storm (x0.6)\n"+
        "  autumn 0.6 because\n"+
        "      If leafs are: falling (x1) and weather is: cold (x1) then time of season is: autumn (x1)\n"+
        "      falling 0.6 because\n"+
        "          It is user input\n"+
        "      cold 1.0 because\n"+
        "          It is user input\n"+
        "  cloudy 0.7 because\n"+
        "      It is user input\n"]
    assert_equal explanation, text
  end

  def test_explanation_text_if_nil
    @table.source = Mock.new :ask, lambda{ |key|
      nil
    }
    goal = 'unreachable goal'
    r1= FuzzyRule.new({'value' => 'key'})
    @system.add r1
    @system.goal=goal
    text =  FuzzyExplanator.explain_in_text @system.result, @table
    explanation = 'Nothing satisfies the criteria'
    assert_equal explanation, text
  end

end
