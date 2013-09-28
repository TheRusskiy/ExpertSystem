require 'qt'
require_relative 'translation_patch'
require_relative 'expert_window'
app = Qt::Application.new(ARGV)
window = ExpertWindow.new
window.show
app.exec