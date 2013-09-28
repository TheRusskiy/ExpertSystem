require_relative 'test_helper'

class TestFactTable < MiniTest::Unit::TestCase
  def setup
    @table = FactTable.new
  end

  def teardown
    # Do nothing
  end

  def test_acts_like_hash
    @table['key']='value'
    assert_equal(@table['key'], 'value')
    #assert_equal(@table['shit'], nil)
  end


  def test_asks_external_source
    source = Minitest::Mock.new
    source.expect :ask, 'true_value', [:unknown_property]
    @table.source=source
    @table[:unknown_property]
    source.verify
  end

  def test_tables_caches_values
    #call 1st time
    source = Minitest::Mock.new
    source.expect :ask, 'true_value', [:unknown_property]
    @table.source=source
    @table[:unknown_property]
    source.verify

    #call 2nd time
    fakeSource = Class.new do
      def ask(key)
        fail('Value must be cached!')
      end
    end

    #noinspection RubyArgCount
    @table.source = fakeSource.new() # intellij idea highlights this as an error for no reason
    @table[:unknown_property]
    # if no error raised => value cached
  end

  def test_table_can_detect_changes
    refute @table.changed?
    @table[:some_property]='value'
    assert @table.changed?
    @table.reset_changed
    refute @table.changed?
  end

end
      