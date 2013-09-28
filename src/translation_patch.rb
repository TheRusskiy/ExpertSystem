# encoding: UTF-8
class Object
  def self.translation_map= map
    @translation_map = map
  end

  def self.translation_map
    @translation_map||={}
  end

  def tr text
    Object.translation_map[text.downcase]||text
  end
end

require 'yaml'
Object.translation_map = YAML::load File.open('../src/translation.yml')