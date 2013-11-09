# encoding: UTF-8
class Object
  def self.translation_map= map
    @translation_map = map
  end

  def self.translation_map
    @translation_map||={}
  end

  def tr text
    translated = Object.translation_map[text.downcase]
    if translated.nil?
      puts "Can't find translation for:\n#{text}"
      Object.translation_map[text.downcase] = text
    end
    translated||text
  end
end

require 'yaml'
Object.translation_map = YAML::load File.open('../src/translation.yml')