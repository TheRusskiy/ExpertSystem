require_relative 'test_helper'

class TestFuzzyFactTable < MiniTest::Unit::TestCase
  def setup
    @table = FuzzyFactTable.new
  end

  def teardown
    # Do nothing
  end

  def test_inc_on_access
    @table.source = Mock.new :ask do |n| nil end
    @table['property','value']=0.4
    assert_in_delta @table['property', 'value'], 0.4
    @table['property', 'value']=0.2
    assert_in_delta @table['property', 'value'], 0.6
    assert_equal(@table['ass', 'hole'], nil)
  end

  def test_raises_if_more_than_one
    @table.source = Mock.new :ask do |n| nil end
    assert_raises(FuzzyFactTable::MoreThanOneException) do
      @table['prop', 'key']=1.1
    end
    assert_raises(FuzzyFactTable::MoreThanOneException) do
      @table['prop', 'key_2']=0.5
      @table['prop', 'key_2']=0.6
    end
  end


  def test_asks_external_source
    source = Mock.new :ask, lambda { |p|
      return nil unless p == 'p1'
      return 'k1' => 0.1
    }
    @table.source=source
    assert_equal @table['p1', 'k1'], 0.1
  end

  def test_can_work_with_symbols
    @table['p1','v1']=0.1
    assert_in_delta @table[:p1, :v1], 0.1

    @table[:p2, :v2]=0.2
    assert_in_delta @table['p2', 'v2'], 0.2
  end

  def test_table_caches_values
    #call 1st time
    source = Mock.new :ask, lambda{ |p|
      raise Exception.new if @asked_before
      raise Exception.new unless p == 'property'
      @asked_before = true
      return 'key'=>0.1
    }
    @table.source=source
    assert_in_delta @table['property', 'key'], 0.1
    assert_in_delta @table['property', 'key'], 0.1
    # if no exception raised => value cached
  end

  def test_table_can_detect_changes
    refute @table.changed?
    @table['p', 'k']=0.5
    assert @table.changed?
    @table.reset_changed
    refute @table.changed?
  end

end
      