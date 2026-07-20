(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(3, 3);
	self[\currentBeat] = 0;
	self[\selectedBeat] = nil;
	self[\valueModifiesTrack] = true;

	self[\title] = ~gmWidgets.getTitle;

	self[\envWidget] = ~gmWidgets.getEnv
	.setDisplayTimeHelpers(true)
	.connectSignal(
		\_envChanged,
		{ |env| self.updateEnv(env); },
		self
	);

	self[\timeScaleSlider] = ~gmWidgets.getSymbolSlider
	.setMaxHeight(32)
	.displayLine(false)
	.orientation(\horizontal)
	.min(0.01)
	.max(8)
	.value(self[\envWidget].getTimeScale)
	.connectSignal(
		\_valueChanged,
		{ |value| self[\envWidget].setTimeScale(value); },
		self
	);

	// MENU
	self[\menu] = ~gmWidgets.getMenu
	.setOrientation(\horizontal);
	self[\modeSwitch] = self[\menu].addSwitch
	.fontRatio(0.8)
	.states([
		(
			string: "",
			color: Color.black,
			svg: ~gmWidgets.getIcon(\slider)
		),
		(
			string: "",
			color: Color.black,
			svg: ~gmWidgets.getIcon(\multiSlider)
		)
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			if(self[\param].notNil) {
				switch(state)
				{ 0 } {
					self[\param].setMode(\value);
				}
				{ 1 } {
					self[\param].setMode(\track);
				};
			};
		},
		self
	);
	self[\copyButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\copy))
	.connectSignal(
		\_buttonPressed,
		{
			~gmDefs.doCopy(
				\env,
				self[\envWidget].getEnv
			);
		},
		self
	);
	self[\pasteButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\paste))
	.connectSignal(
		\_buttonPressed,
		{
			if(~gmDefs[\copyPaste][\env].notNil) {
				// FIX ME: ENV MAX SIZE CHECK
				self.updateEnv(
					~gmDefs[\copyPaste][\env]
				);
			};
		},
		self
	);

	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\menu][\view], 1)
		.add(self[\envWidget][\view], 3)
		.add(self[\timeScaleSlider][\view], 1)
	)
	.onClose_({
		if(self[\removed].not) {
			self[\view] = nil;
			self.doRemove;
		};
	});

	self
},

setParam: { |self, param, paramDict|
	if(self[\param].notNil) {
		self[\param].disconnectNode(self);
	};
	if(self[\rhythm].notNil) {
		self[\rhythm].disconnectNode(self);
	};
	if(self[\player].notNil) {
		self[\player].disconnectNode(self);
	};

	self[\param] = param;
	self.name(paramDict[\text]);

	if(param[\mode] == \value) {
		self.env(param[\value].copy);
		self[\modeSwitch].state(0);
	} {
		if(self[\selectedBeat].isNil) {
			self.syncEnv;
		} {
			self.selectEnv;
		};
		self[\modeSwitch].state(1);
	};

	param.connectSignal(
		\_valueChanged, { |env|
			if(param[\mode] == \value) {
				self[\envWidget].env(env.copy);
			};
		};
	);

	param.connectSignal(
		\_trackChanged, { |env|
			if(param[\mode] == \track) {
				if(self[\selectedBeat].isNil) {
					self.syncEnv;
				} {
					self.selectEnv;
				};
			};
		};
	);

	param.connectSignal(
		\_modeChanged, { |mode|
			if(mode == \value) {
				self.env(param[\value].copy);
				self[\modeSwitch].state(0);

			} {
				if(self[\selectedBeat].isNil) {
					self.syncEnv;
				} {
					self.selectEnv;
				};
				self[\modeSwitch].state(1);
			};
		};
	);

	// Rhythm
	if(param[\rhythm].notNil) {
		self[\rhythm] = param[\rhythm];
		self[\rhythm][\player].connectSignal(
			\_postBeat,
			{ |beat|
				self.displayBeat(beat);
			},
			self
		);
		self[\player] = self[\rhythm][\player];
		self[\player].connectSignal(
			\_stopped,
			{
				self[\currentBeat] = 0;
				self.syncEnv;
			},
			self
		);
		self[\player].connectSignal(
			\_divChanged,
			{ self.updateTimeHelpers; },
			self
		);
		self[\player].connectSignal(
			\_bpmChanged,
			{ self.updateTimeHelpers; },
			self
		);
		self.updateTimeHelpers;
	};

	param.connectSignal(
		\_rhythmChanged,
		{ |rhythm|
			if(self[\rhythm].notNil) {
				self[\rhythm].disconnectNode(self);
			};
			if(self[\player].notNil) {
				self[\player].disconnectNode(self);
			};
			self[\rhythm] = rhythm;
			self[\player] = rhythm[\player];
			rhythm[\player].connectSignal(
				\_postBeat,
				{ |beat|
					self.displayBeat(beat);
				},
				self
			);
			rhythm[\player].connectSignal(
				\_stopped,
				{
					self[\currentBeat] = 0;
					self.syncEnv;
				},
				self
			);
		};
	);

	self
},

//---------//
// METHODS //
name: { |self, name|
	self[\title].string_(name);
},

deselectBeat: { |self|
	if(self[\selectedBeat].notNil) {
		self[\selectedBeat] = nil;
		if(self[\param][\mode] == \track) {
			self.syncEnv;
		} {
			self.env(self[\param][\value]);
		};
	};
},

selectBeat: { |self, index|
	if(self[\selectedBeat] != index) {
		self[\selectedBeat] = index;
		self.selectEnv;
	};
},

displayBeat: { |self, beat|
	var canPlay = false;
	(self[\rhythm][\depth] + 1).do({ |index|
		if(canPlay.not) {
			canPlay = (
				beat[\beatDetection][index]
				== 1
			);
		};
	});
	if(canPlay) {
		self[\currentBeat] =
		(beat[\absGrid][self[\rhythm][\depth]] - 1)
		+ self[\rhythm][\offset]
		% self[\param][\track].size;
		self.syncEnv;
	};
},

selectEnv: { |self|
	if(self[\param][\mode] == \track) {
		self.env(
			self[\param][\track]
			[self[\selectedBeat]]
		);
	};
},

syncEnv: { |self|
	if(
		(self[\param][\mode] == \track)
		and:
		{ self[\selectedBeat].isNil }
	) {
		self.env(
			self[\param][\track]
			[self[\currentBeat]]
		);
	};
},

updateEnv: { |self, env|
	var newTrack;
	env = env.copy;
	if(self[\param][\mode] == \value) {
		self[\param].setValue(env);
		if(self[\valueModifiesTrack]) {
			newTrack = Array.fill(
				self[\rhythm][\size],
				{ env.copy }
			);
			self[\param].setTrack(newTrack);
		};
	} {
		newTrack = self[\param][\track].copy;
		if(self[\selectedBeat].isNil) {
			newTrack[self[\currentBeat]] = env.copy;
			self[\param].setTrack(newTrack);
		} {
			newTrack[self[\selectedBeat]] = env.copy;
			self[\param].setTrack(newTrack);
		};
	};
},


updateTimeHelpers: { |self|
	var time = 60;
	var alphas;
	if(self[\player].notNil) {
		time = time / self[\player][\bpm];
		if(self[\player][\divisions].size > 1) {
			time = time / self[\player][\divisions][1];
			alphas = Array.fill(
				self[\player][\divisions][1],
				{ 0.5 }
			);
		};
		if(self[\player][\divisions].size > 2) {
			time = time / self[\player][\divisions][2];
			alphas = List(0);
			self[\player][\divisions][1].do({
				alphas.add(0.6);
				(self[\player][\divisions][2] - 1).do({
					alphas.add(0.3);
				});
			});
		};
		alphas[0] = 1;
		self[\envWidget].setHelpersTime(time);
		self[\envWidget].setTimeHelpersAlpha(alphas);
	};
},

removed: false,
doRemove: { |self|
	if(self[\view].notNil) {
		self[\removed] = true;
		self[\view].remove;
	};
	self.emitSignal(\_removed);
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\envWidget].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\timeScaleSlider].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\title].style_(textStyle);
},

//---------//
// PROXIES //
env: { |self, env|
	self[\envWidget].env(env);
},
)