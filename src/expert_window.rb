class ExpertWindow < Qt::MainWindow
  slots :close_program, :about, :switch_to_expert_mode, :switch_to_user_mode

  def initialize(parent = nil)
    super(parent)
    #initialize:
    setWindowTitle("Expert System")
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

  def create_user_widget()
    @user_widget = Qt::GroupBox.new 'User mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout

    @user_widget.layout=layout
    @user_widget
  end

  def create_expert_widget()
    @expert_widget = Qt::GroupBox.new 'Expert Mode'
    layout = Qt::GridLayout.new

    # Add widgets to layout

    @expert_widget.layout=layout
    @expert_widget
  end

  def create_actions
    @exit_action = Qt::Action.new('Exit', self)
    @exit_action.shortcut = Qt::KeySequence.new( 'Ctrl+X' )
    @exit_action.statusTip = 'Close the program'
    connect(@exit_action, SIGNAL(:triggered), self, SLOT(:close_program))

    @switch_to_expert_mode = Qt::Action.new('Expert mode', self)
    @switch_to_expert_mode.shortcut = Qt::KeySequence.new( 'Ctrl+E' )
    @switch_to_expert_mode.checkable = true
    @switch_to_expert_mode.statusTip = 'In this mode you can edit rules'
    connect(@switch_to_expert_mode, SIGNAL(:triggered), self, SLOT(:switch_to_expert_mode))

    @switch_to_user_mode = Qt::Action.new('User mode', self)
    @switch_to_user_mode.shortcut = Qt::KeySequence.new( 'Ctrl+U' )
    @switch_to_user_mode.checkable = true
    @switch_to_user_mode.statusTip = 'In this mode you can get recommendations'
    connect(@switch_to_user_mode, SIGNAL(:triggered), self, SLOT(:switch_to_user_mode))


    @about_action = Qt::Action.new('About', self)
    @about_action.statusTip = 'Show information about the program'
    connect(@about_action, SIGNAL(:triggered), self, SLOT(:about))
  end

  def create_menus
    @file_menu = menuBar.addMenu('File')
    @file_menu.addAction(@exit_action)

    @mode_menu = menuBar.addMenu('Mode')
    @mode_menu.addAction(@switch_to_user_mode)
    @mode_menu.addAction(@switch_to_expert_mode)

    @help_menu = menuBar.addMenu('Help')
    @help_menu.addAction(@about_action)
  end

  def create_status_bar
    statusBar().showMessage('Welcome!')
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
    about_message = tr(            "MINISTRY OF EDUCATION AND SCIENCE\n"+
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
                                       "Instructor: associate professor Valentin Deryabkin")

    Qt::MessageBox::information(self, "About", about_message)
  end

end