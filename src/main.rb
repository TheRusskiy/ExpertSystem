require 'Qt'
require 'awesome_print'
require_relative '../src/expert_window'
app = Qt::Application.new(ARGV)
window = ExpertWindow.new
window.show
app.exec