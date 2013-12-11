# encoding: UTF-8
class ExpertWindow < Qt::MainWindow
  require_relative 'expert_system'
  require_relative 'fuzzy_rule'
  require_relative 'fuzzy_parser'
  require_relative 'fuzzy_fact_table'
  require_relative 'fuzzy_explanator'
  require_relative 'highlighter'
  require 'yaml'

  slots :close_program, :about, :switch_to_expert_mode, :switch_to_user_mode,
        'start_consultation()', 'load_rule_file()', 'save_rule_file()', 'switch_to_help_mode()'

  class WindowSource < Qt::MainWindow
    slots   'spinbox_changed(double)', 'accepted()',  'rejected()', 'accept_dialog()'
    def initialize(options, parent)
      super(nil)
      @parent = parent
      @options=options
      @boxes = []
    end

    def ask property, current_rule=nil
      select_item property, current_rule
    end

    def select_item property, current_rule=nil
      return if property.nil? or @options[property].nil?

      @dialog = Qt::Dialog.new(self)
      @dialog.setWindowTitle(tr('Additional information needed')+': '+property)
      connect(@dialog, SIGNAL('accepted()'), self,  SIGNAL('accepted()'))
      connect(@dialog, SIGNAL('rejected()'), self,  SIGNAL('rejected()'))
      layout = Qt::GridLayout.new
      i=0
      layout.addWidget Qt::Label.new(''+current_rule.to_s(true)+'<br/>'), i, 0, 1, 2
      i+=1
      layout.addWidget Qt::Label.new('<b>'+property.capitalize+':</b>'), i, 0, 1, 2
      i+=1
      @options[property].each do |option_item|
        label_and_box = create_option_spin_box property, option_item, (@step || 100)
        layout.addWidget label_and_box[0], i, 0
        layout.addWidget label_and_box[1], i, 1
        i+=1
      end

      @step||=10

      accept_button = Qt::PushButton.new(tr 'Ok')
      layout.addWidget accept_button, i, 0, 1, 2
      connect(accept_button, SIGNAL('clicked()'), self, SLOT('accept_dialog()'))

      @dialog.layout = layout
      @dialog.exec

      result_hash = {}
      @options[property].each_with_index do |option_item, i|
        result_hash[option_item] = @boxes[i].value/100.0
      end

      @boxes = []

      result_hash
    end


    def create_option_spin_box property, key, step=10
      confidence=[0, 100, 0]
      confidenceLabel = Qt::Label.new("#{key}:")
      confidenceSpinBox = Qt::DoubleSpinBox.new do |i|
        i.range = confidence[0]..confidence[1]
        i.singleStep = step
        i.value = confidence[2]
        i.suffix = ' %'
      end
      connect(confidenceSpinBox, SIGNAL('valueChanged(double)'), self,
              SIGNAL('spinbox_changed(double)'))
      @boxes << confidenceSpinBox
      [confidenceLabel, confidenceSpinBox]
    end

    def spinbox_changed value
      sum = 0
      @boxes.each do |box|
        sum+=box.value
      end
      @boxes.each do |box|
        box.range= 0..(box.value+(100-sum))
      end
    end

    def accept_dialog
      @dialog.accept
    end
    def accepted
    end
    def rejected
    end
  end


  def initialize(parent = nil)
    super(parent)
    #initialize:
    setWindowTitle(tr "Expert System")
    create_actions
    create_menus
    create_status_bar

    #layout:
    @w = Qt::Widget.new
    @w.layout = Qt::GridLayout.new
    setCentralWidget(@w)
    @w.layout.addWidget(create_user_widget, 0, 0)
    @w.layout.addWidget(create_expert_widget, 0, 0)
    @w.layout.addWidget(create_help_widget, 0, 0)

    #set correct state:
    resize(600, 400)
    load_rule_file 'fuzzy_rules.yml' if File.exist? ('fuzzy_rules.yml')
    switch_to_user_mode
  end

  def create_expert_system
    begin
      @fact_table = FuzzyFactTable.new

      @system = ExpertSystem.new @fact_table
      rules_hash = YAML::load @rule_editor.plainText
      raise Exception unless rules_hash
      @system.add FuzzyParser.parse_rules(rules_hash['rules'])
      @system.goal = rules_hash['goal']

      @information_source = WindowSource.new rules_hash['options'], self
      @fact_table.source = @information_source
      @fact_table.algebra = rules_hash['algebra']
      true
    rescue Exception => e
      show_warning tr "Can't parse rules"
      puts e.message
      false
    end
  end

  def start_consultation
    if create_expert_system
      @explanation_box.text = format_result(
          FuzzyExplanator.explain_in_text(@system.result, @fact_table),
          @system.rules_activated,
        @fact_table.algebra)
    end
  end

  def human_algebra algebra
    result="Алгебра (a): "
    result+="(min(cfa, cfb) + cfa*cfb)/2<br/>"
    result+="Алгебра подтверждения "
    algebra||='sum'
    case algebra
      when 'sum' then begin
        result+= "sum"
      end
      when 'am' then begin
        result+= "(m): max(cfa, cfb)"
      end
      when 'ap' then begin
        result+= "(p): cfa+cfb-cfa*cfb/2"
      end
      else
        raise Exception.new 'Unknown algebra: '+algebra
    end
    result
  end

  def format_result text, rules_activated, algebra
    if text.respond_to? :each
      text = text * "\n"
    end
    "<font size=\"4\"><pre>"+
    "#{human_algebra(algebra)}<br/>"+
    "#{tr('Number of rules activated')}: #{rules_activated.to_s}\n"+
    "#{@system.goal+":\n #{text}"}"+
    "</pre></font>"
  end

  def save_rule_file(path = nil)
    filled_name=""
    path||= Qt::FileDialog.getSaveFileName(self,
                                              tr('Save File'),
                                              filled_name,
                                              tr('YAML files (*.yml)'))
    text = @rule_editor.plainText
    file = File.open path, 'w:utf-8'
    file.write text
    file.close
  end

  def load_rule_file(path = nil)
    filled_name=""
    path||= Qt::FileDialog.getOpenFileName(self,
                tr('Open File'), filled_name, "YAML files (*.yml)")
    return if path.nil?
    file = File.open path, 'r:utf-8'
    set_rule_text file.to_a.reduce :+
    file.close
  end

  def show_warning message
    reply = Qt::MessageBox::critical(self, tr('Error'),
                                     message,
                                     Qt::MessageBox::Retry)
  end

  def set_rule_text text
    @rule_editor.plainText= text
  end

  def create_user_widget()
    @user_widget = Qt::GroupBox.new tr 'User mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout
    frameStyle = Qt::Frame::Sunken | Qt::Frame::Panel
    @explanation_box = Qt::Label.new
    #@explanation_box.format.fontPointSize = @fontSize
    #Qt::Label.new(tr("<center><font color=\"blue\" size=\"5\"><b><i>" +
    #                     "Super Product One</i></b></font></center>"))
    @explanation_box.frameStyle = frameStyle
    start_button = Qt::PushButton.new(tr('Start Consultation'))
    layout.addWidget start_button, 0, 0, 4
    layout.addWidget @explanation_box, 1, 0
    connect(start_button, SIGNAL('clicked()'), self, SLOT('start_consultation()'))

    @user_widget.layout=layout
    @user_widget
  end

  def create_expert_widget()
    @expert_widget = Qt::GroupBox.new tr 'Expert Mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout
    frameStyle = Qt::Frame::Sunken | Qt::Frame::Panel
    @rule_editor = setupEditor
    @rule_editor.frameStyle = frameStyle

    load_button = Qt::PushButton.new(tr('Load rule file'))
    load_button.statusTip = tr 'Load rule file' # todo more informative tip?
    load_button.shortcut = Qt::KeySequence.new( 'Ctrl+O' )
    connect(load_button, SIGNAL('clicked()'), self, SLOT('load_rule_file()'))

    save_button = Qt::PushButton.new(tr('Save rule file'))
    save_button.statusTip = tr 'Save rule file' # todo more informative tip?
    save_button.shortcut = Qt::KeySequence.new( 'Ctrl+S' )
    connect(save_button, SIGNAL('clicked()'), self, SLOT('save_rule_file()'))


    layout.addWidget load_button, 0, 0
    layout.addWidget save_button, 0, 1
    layout.addWidget @rule_editor, 1, 0, 1, 2

    @expert_widget.layout=layout
    @expert_widget
  end

  def create_help_widget()
    @help_widget = Qt::GroupBox.new tr 'Help'
    layout = Qt::GridLayout.new


    # Add widgets to layout
    help_information = tr 'help information'
    if help_information == 'help information'
      help_information = 'Table below shows rules'
    end
    help_label = Qt::Label.new help_information
    layout.addWidget help_label, 0,0;

    image = Qt::Pixmap.new('table.png');
    imageLabel = Qt::Label.new();
    imageLabel.setPixmap(image);
    layout.addWidget imageLabel, 1,0;

    @help_widget.layout=layout
    @help_widget
  end

  def setupEditor()
    highlighter = Highlighter.new
    commentFormat = Qt::TextCharFormat.new
    commentFormat.foreground = Qt::Brush.new(Qt::Color.new("#8b3d06"))
    highlighter.addMapping('#.*', commentFormat)

    keywordsFormat = Qt::TextCharFormat.new
    keywordsFormat.fontWeight = Qt::Font::Bold
    keywordsFormat.foreground = Qt::Brush.new(Qt::Color.new("#ff587c"))
    highlighter.addMapping("((goal)|(options)|(rules)|(if)|(then)):", keywordsFormat)

    font = Qt::Font.new
    font.family = "Courier"
    font.fixedPitch = true
    font.pointSize = 10

    editor = Qt::TextEdit.new
    editor.font = font
    highlighter.addToDocument(editor.document())
    editor
  end

  def create_actions
    @exit_action = Qt::Action.new(tr('Exit'), self)
    @exit_action.shortcut = Qt::KeySequence.new( 'Ctrl+X' )
    @exit_action.statusTip = tr 'Close the program'
    connect(@exit_action, SIGNAL(:triggered), self, SLOT(:close_program))

    @switch_to_expert_mode = Qt::Action.new(tr('Expert mode'), self)
    @switch_to_expert_mode.shortcut = Qt::KeySequence.new( 'Ctrl+E' )
    @switch_to_expert_mode.checkable = true
    @switch_to_expert_mode.statusTip = tr 'In this mode you can edit rules'
    connect(@switch_to_expert_mode, SIGNAL(:triggered), self, SLOT(:switch_to_expert_mode))

    @switch_to_user_mode = Qt::Action.new(tr('User mode'), self)
    @switch_to_user_mode.shortcut = Qt::KeySequence.new( 'Ctrl+U' )
    @switch_to_user_mode.checkable = true
    @switch_to_user_mode.statusTip = tr 'In this mode you can get recommendations'
    connect(@switch_to_user_mode, SIGNAL(:triggered), self, SLOT(:switch_to_user_mode))

    @help_action = Qt::Action.new(tr('Help'), self)
    @help_action.statusTip = tr 'Show help'
    @help_action.shortcut = Qt::KeySequence.new( 'Ctrl+H' )
    connect(@help_action, SIGNAL(:triggered), self, SLOT(:switch_to_help_mode))

    @about_action = Qt::Action.new(tr('About'), self)
    @about_action.statusTip = tr 'Show information about the program'
    connect(@about_action, SIGNAL(:triggered), self, SLOT(:about))
  end

  def create_menus
    @file_menu = menuBar.addMenu(tr 'File')
    @file_menu.addAction(@exit_action)

    @mode_menu = menuBar.addMenu(tr 'Mode')
    @mode_menu.addAction(@switch_to_user_mode)
    @mode_menu.addAction(@switch_to_expert_mode)

    @help_menu = menuBar.addMenu(tr 'Help')
    @help_menu.addAction(@about_action)
    @help_menu.addAction(@help_action)
  end

  def create_status_bar
    statusBar().showMessage(tr 'Welcome!')
  end

  def close_program
    exit
  end

  def switch_to_expert_mode
    @switch_to_user_mode.checked=false
    @switch_to_expert_mode.checked=true
    @user_widget.visible=false
    @expert_widget.visible=true
    @help_widget.visible=false
  end

  def switch_to_user_mode
    @switch_to_user_mode.checked=true
    @switch_to_expert_mode.checked=false
    @user_widget.visible=true
    @expert_widget.visible=false
    @help_widget.visible=false
  end

  def switch_to_help_mode
    @switch_to_user_mode.checked=false
    @switch_to_expert_mode.checked=false
    @user_widget.visible=false
    @expert_widget.visible=false
    @help_widget.visible=true
  end

  def about
    about_message = tr('long about');
    if about_message=='long about'
      about_message=
          "MINISTRY OF EDUCATION AND SCIENCE\n"+
          "OF THE RUSSIAN FEDERATION\n"+
          "FEDERAL STATE EDUCATIONAL INSTITUTION\n"+
          "OF HIGHER PROFESSIONAL EDUCATION\n"+
          "\"SAMARA STATE AEROSPACE UNIVERSITY\n" +
          "OF ACADEMICIAN S.P. KOROLYOV\"\n" +
          "(NATIONAL RESEARCH UNIVERSITY) (SSAU) \n" +
          "Chair of Computer Systems\n" +
          "\n" +
          "Authors: \n" +
          "Dmitry Ishkov\n"+
          "Anton Shabanov\n"+
          "Group: 6502 C 245\n" +
          "Instructor: associate professor Valentin Deryabkin"
    end


    Qt::MessageBox::information(self, tr('About'), about_message)
  end

end