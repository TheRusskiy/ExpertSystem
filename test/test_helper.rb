require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new
require '../src/expert_system'
require '../src/fact_table'
require '../src/rule'
require '../src/result_value'
require '../src/explanator'