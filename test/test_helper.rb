# encoding: UTF-8
require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use! MiniTest::Reporters::RubyMineReporter.new
require '../src/expert_system'
require '../src/fact_table'
require '../src/fuzzy_fact_table'
require '../src/rule'
require '../src/fuzzy_rule'
require '../src/result_value'
require '../src/explanator'
require '../src/translation_patch'
Object.translation_map = {}
$delta = 0.000001
class Mock
  def initialize(method_name, block = nil )
    block||=Proc.new do |*args|
      args=args.first if args.length==1
      yield(args)
    end
    self.class.send :define_method, method_name, block
  end
end

