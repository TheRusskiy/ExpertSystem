require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new

class TestTemplate < MiniTest::Unit::TestCase
  def setup
    # Do nothing
  end

  def teardown
    # Do nothing
  end

  # All test MUST start with "test"!
  #def test_XXX
  #  fail("Not implemented")
  #end

end
      