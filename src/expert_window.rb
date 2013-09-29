class ExpertWindow < Qt::MainWindow
  require_relative 'expert_system'
  require_relative 'fact_table'
  require_relative 'explanator'
  require 'yaml'

  slots :close_program, :about, :switch_to_expert_mode, :switch_to_user_mode,
        'start_consultation()'

  class WindowSource  < Qt::MainWindow
    @options

    def initialize(options)
      super(nil)
      @options=options
    end

    def ask key
      select_item key
    end

    def select_item key
      return if key.nil? or @options[key].nil?
      ok = Qt::Boolean.new
      item = Qt::InputDialog.getItem(self, tr('Additional information needed'),
                                     key, @options[key].values, 0, false, ok)
      unless ok.value
         item = select_item key
      end
      item
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

    #set correct state:
    resize(600, 400)
    switch_to_user_mode
  end

  def create_expert_system
    @fact_table = FactTable.new

    @system = ExpertSystem.new @fact_table
    rules_hash = YAML::load File.open('rules.yml')
    parse_rules(rules_hash['rules']).each do |rule|
      @system.add rule
    end
    @system.goal = rules_hash['goal']

    @information_source = WindowSource.new rules_hash['options']
    @fact_table.source = @information_source
  end

  def parse_rules hash
    rules = []
    hash.each_value do |r|
      rules << Rule.new(r['if'], r['then'])
    end
    rules
  end

  def start_consultation
    create_expert_system
    @explanation_box.text = Explanator.explain_in_text @system.result, @fact_table
  end

  def create_user_widget()
    @user_widget = Qt::GroupBox.new tr 'User mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout
    frameStyle = Qt::Frame::Sunken | Qt::Frame::Panel
    @explanation_box = Qt::Label.new
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

    @expert_widget.layout=layout
    @expert_widget
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
  end

  def switch_to_user_mode
    @switch_to_user_mode.checked=true
    @switch_to_expert_mode.checked=false
    @user_widget.visible=true
    @expert_widget.visible=false
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