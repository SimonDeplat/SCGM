(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\connectedSynths] = List(0);
	self.initView;

	self
},

//--------//
//  VIEW  //
initView: { |self|
	self[\stretch] = Point(1, 1);

	self[\view] = UserView()
	.acceptsMouseOver_(true)
	.onResize_({ |view|
		if(view.bounds.height > 96) {
			self[\normalView].visible_(true);
		} {
			self[\normalView].visible_(false);
		};
	})
	.layout_(
		StackLayout()
		.margins_(0)
	);

	self[\mainView] = UserView()
	.acceptsMouseOver_(true);

	self[\title] = ~gmWidgets.getTitle;
	self[\menu] = ~gmWidgets.getMenu;

	// Manager
	self[\hidePMButton] = self[\menu].addSwitch
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\params),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\params),
			color: Color.black
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self[\paramManager].visible(true);
			}
			{ 1 } {
				self[\paramManager].visible(false);
			};
		},
		self
	);

	// Rhythm
	self[\rhythmView] = ~gmWidgets.getRhythmView;
	self[\rhythmButton] = self[\menu].addSwitch
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\rhythm),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\rhythm),
			color: Color.black
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self.showRhythmView(true);
			}
			{ 1 } {
				self.showRhythmView(false);
			};
		},
		self
	);
	self.showRhythmView(false);

	// Beat Selector
	self[\beatSelector] = ~gmWidgets.getBeatSelector
	.maxHeight(32)
	.setVisible(false)
	.connectSignal(
		\_beatDeselected,
		{ self[\paramManager].deselectBeat; },
		self
	)
	.connectSignal(
		\_beatSelected,
		{ |beat|
			self[\paramManager].selectBeat(beat);
		},
		self
	);
	self[\beatSelectorButton] = self[\menu].addSwitch
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\beatSelector),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\beatSelector),
			color: Color.black
		)
	])
	.state(1)
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self[\beatSelector].setVisible(true);
			}
			{ 1 } {
				self[\beatSelector].setVisible(false);
			};
		},
		self
	);

	// PianoRoll
	self[\pianoRollButton] = self[\menu].addSwitch
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\pianoRoll),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\pianoRoll),
			color: Color.black
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self[\pianoRollView].visible(true);
			}
			{ 1 } {
				self[\pianoRollView].visible(false);
			};
		},
		self
	);

	// Modulate Persistent
	self[\modPersistentButton] = self[\menu].addSwitch
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\modulatePersistent),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\modulatePersistent),
			color: Color.black
		)
	])
	.state(1)
	.visible(false)
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self[\synth].setModulatePersistent(true);
			}
			{ 1 } {
				self[\synth].setModulatePersistent(false);
			};
		},
		self
	);

	// FIX ME: GENERATE ON SYNTH IS TUNABLE
	// Piano Roll
	self[\pianoRollView] = ~gmWidgets.getPianoRollView
	.visible(false);

	self.initParamManager;

	self[\normalView] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
	)
	.acceptsMouseOver_(true);

	self[\mainLayout] =
	HLayout()
	.margins_(0)
	.spacing_(0)
	.add(self[\menu][\view], 1)
	.add(self[\rhythmView][\view], 1)
	.add(self[\normalView], 8);

	self[\mainView].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\mainLayout], 7)
	);

	self[\view].layout.add(self[\mainView]);

	self[\normalView].layout
	.add(self[\pianoRollView][\view], 4)
	.add(self[\paramManager][\view], 4)
	.add(self[\beatSelector][\view], 1);

	self.setStyles(
		~gmWidgets[\style],
		~gmWidgets[\textStyle],
		~gmWidgets[\widgetStyle]
	);
},

initMenu: { |self|
	self[\menu] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(4)
	)
	.maxHeight_(64);
},

initParamManager: { |self|
	self[\paramManager] = ~gmWidgets.getParamManager;
	self[\paramManager].connectSignal(
		\_stretch,
		{ self.updateStretch }
	);
},

getParam: { |self, param|
	self[\paramManager].getParam(param);
},

hideParam: { |self, param|
	self[\paramManager].hideParam(param);
	self
},

name: { |self, name|
	self[\title].string_(name);
	self
},

//---------//
//  SYNTH  //

setSynth: { |self, synth|
	self.adaptToSynth(synth);
	self[\synth] = synth;
	self[\title].string_(synth[\name]);
	// FIX ME: SYNTH MUST HAVE RHYTHM
	if(synth[\rhythm].notNil) {
		self[\rhythmView].setRhythm(synth[\rhythm]);
	};

	// if not tunable and continuous
	// disable hide param manager
	if(
		synth[\tunable].not
		and:
		{ synth[\datas][\emission] == \continuous }
	) {
		self[\hidePMButton].visible(false);
	} {
		self[\hidePMButton].visible(true);
	};

	if(synth[\tunable]) {
		self[\pianoRollView]
		.setScore(synth[\score])
		.setPlayer(synth[\player])
		.visible(true);
		self[\pianoRollButton].visible(true);
	} {
		self[\pianoRollButton].visible(false);
	};
	// FIX ME: connect rhythm changed
	self[\paramManager].setSynth(synth);
	if(synth[\triggers].notNil) {
		if(self[\triggerView].isNil) {
			self.initTriggerView;
		};
		self[\triggerView].setSynth(synth);
	};
	synth.connectSignal(
		\_triggersChanged, { |triggers|
			if(self[\triggerView].isNil) {
				self.initTriggerView;
				self[\triggerView].connectSignal(
					\_valuesChanged, { |triggers|
						synth.setTriggers(triggers);
					};
				);
			};
			self[\triggerView].setValues(triggers);
		},
		self
	);

	// Bind beatSelector
	if(synth[\rhythm].notNil) {
		self[\beatSelector].setRhythm(
			synth[\rhythm]
		);
		self[\beatSelectorButton].visible(true);
	} {
		self[\beatSelector].setVisible(false);
		self[\beatSelectorButton].visible(false);
	};

	// Activate modulate persistent
	// if synth is discrete
	if(synth[\datas][\emission] == \discrete) {
		self[\modPersistentButton].visible(true);
		if(synth[\modulatePersistent]) {
			self[\modPersistentButton].state(0);
		} {
			self[\modPersistentButton].state(1);
		};
	} {
		self[\modPersistentButton].visible(false);
	};

	// Bind player
	if(synth[\player].notNil) {
		self.setPlayer(synth[\player]);
	};

	self
},

initTriggerView: { |self|
	self[\triggerView] = ~gmWidgets.getTriggerView;
	self[\normalView].layout
	.insert(self[\triggerView][\view], 2, 1);
	self[\triggerButton] = self[\menu].addSwitch
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\tracker),
			color: Color(0.1, 0.3, 0.3)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\tracker),
			color: Color.black
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self.showTriggerView(true);
			}
			{ 1 } {
				self.showTriggerView(false);
			};
		},
		self
	);

	self[\rhythmModeButton] = self[\menu].addSwitch
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\determinist),
			color: Color.black
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\probabilist),
			color: Color.black
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			switch(state)
			{ 0 } {
				self[\triggerView].setMode(\determinist);
			}
			{ 1 } {
				self[\triggerView].setMode(\probabilist);
			};
		},
		self
	);
},


adaptToSynth: { |self, synth|
	var state;
	if(self[\connectedSynths].includes(synth).not) {
		self[\connectedSynths].add(synth);
		self[\paramManager].adaptToSynth(synth);
	};
},

//------------//
//  OUT VIEW  //

hideOut: { |self|
	self[\paramManager].hideOut;
},

getOutView: { |self|
	self[\paramManager].getOutView
},

//---------//
//  STYLE  //

setStyles: { |self, style, textStyle, widgetStyle|
	self[\style] = style;
	self[\textStyle] = textStyle;
	self[\widgetStyle] = widgetStyle;

	self[\title].style_(textStyle);

	self[\menu].setStyles(
		style,
		textStyle,
		widgetStyle
	);

	self[\beatSelector].setStyles(
		style,
		textStyle,
		widgetStyle
	);

	self[\pianoRollView].setStyles(
		style,
		textStyle,
		widgetStyle
	);

	self[\paramManager].setStyles(
		style,
		textStyle,
		widgetStyle
	);

	if(self[\triggerView].notNil) {
		self[\triggerView].setSyles(
			style,
			textStyle,
			widgetStyle
		);
	};

	self
},

//--------//
//  MISC  //

updateStretch: { |self|
	self[\stretch] = Point(1, 1) +
	self[\paramManager][\stretch];
	/*self[\normalView].layout.setStretch(
		0,
		self[\paramManager][\stretch].x
	);*/
	self.emitSignal(\_stretch, self[\stretch]);
},

doRemove: { |self|
	self[\view].destroy;
	self.clear;
},

setMenusVisible: { |self, visible|
	self[\paramManager].setMenusVisible(visible);
	self
},

setSpacing: { |self, spacing|
	self[\mainView].layout
	.spacing_(spacing);
	self[\mainLayout]
	.spacing_(spacing);
	self[\normalView].layout
	.spacing_(spacing);
	self
},

//----------//
//  FIX ME  //

setPlayer: { |self, player|
	self[\player] = player;
	self
},

showRhythmView: { |self, boolean|
	self[\rhythmView][\view].visible_(boolean);
	if(boolean) {
		self[\rhythmButton].state(0);
	} {
		self[\rhythmButton].state(1);
	};
},

showTriggerView: { |self, boolean|
	if(self[\triggerView].notNil) {
		self[\triggerView][\view].visible_(boolean);
		if(boolean) {
			self[\triggerButton].state(0);
		} {
			self[\triggerButton].state(1);
		};
	};
},

displayMenu: { |self, visible|
	self[\menu].visible(visible);
	self
},

displayParamsMenu: { |self, visible|
	self[\paramManager].displayParamsMenu(visible);
	self
},
)