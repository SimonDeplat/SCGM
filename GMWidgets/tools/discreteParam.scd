(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(1, 3);
	self[\currentBeat] = 0;
	self[\selectedBeat] = nil;
	self[\valueModifiesTrack] = true;

	self[\states] = nil;

	self[\title] = ~gmWidgets.getTitle;
	self[\selector] = ~gmWidgets.getSelector
	.maxFontSize(24)
	.connectSignal(
		\_stateChanged, { |index|
			if(self[\param].notNil) {
				self.updateValueIndex(index);
			};
		};
	);
	self[\switch] = ~gmWidgets.getSwitch
	.maxFontSize(24)
	.connectSignal(
		\_stateChanged, { |index|
			if(self[\param].notNil) {
				self.updateValueIndex(index);
			};
		};
	);
	self[\switch].visible(false);

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

	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\menu][\view], 1)
		.add(
			HLayout()
			.add(self[\selector][\view], 1)
			.add(self[\switch][\view], 1),
			3
		)
	)
	.onResize_({ |view|
		var size;

		if(self[\states].notNil) {

			if(view.bounds.height < view.bounds.width) {
				self[\selector].orientation(\horizontal);
				size = view.bounds.width;
			} {
				self[\selector].orientation(\vertical);
				size = view.bounds.height;
			};

			if(size >= (self[\states].size * 32)) {
				self[\switch][\view].visible_(false);
				self[\selector][\view].visible_(true);
				self[\title].visible_(true);
			} {
				if(size > 32) {
					self[\switch][\view].visible_(true);
					self[\selector][\view].visible_(false);
					self[\title].visible_(true);
				} {
					self[\title].visible_(false);
				};
			};
		};
	})
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
	self[\paramDict] = paramDict;
	self.setName(paramDict[\text]);
	self[\states] = paramDict[\texts];
	self[\selector].states(paramDict[\texts]);
	self[\switch].states(paramDict[\texts]);
	self[\state] = param[\value];

	if(param[\mode] == \value) {
		self.displayValue(param[\value]);
		self[\modeSwitch].state(0);
	} {
		if(self[\selectedBeat].isNil) {
			self.syncValue;
		} {
			self.selectValue;
		};
		self[\modeSwitch].state(1);
	};

	param.connectSignal(
		\_valueChanged,
		{ |value|
			if(param[\mode] == \value) {
				self.displayValue(value);
			};
		},
		self
	);

	param.connectSignal(
		\_trackChanged, { |env|
			if(param[\mode] == \track) {
				if(self[\selectedBeat].isNil) {
					self.syncValue;
				} {
					self.selectValue;
				};
			};
		};
	);

	param.connectSignal(
		\_modeChanged, { |mode|
			if(mode == \value) {
				self.displayValue(param[\value]);
				self[\modeSwitch].state(0);

			} {
				if(self[\selectedBeat].isNil) {
					self.syncValue;
				} {
					self.selectValue;
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
				self.syncValue;
			},
			self
		);
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
					self.syncValue;
				},
				self
			);
		};
	);

	self
},

//---------//
// METHODS //
setName: { |self, name|
	self[\title].string_(name);
},

deselectBeat: { |self|
	if(self[\selectedBeat].notNil) {
		self[\selectedBeat] = nil;
		if(self[\param][\mode] == \track) {
			self.syncValue;
		} {
			self.displayValue(self[\param][\value]);
		};
	};
},

selectBeat: { |self, index|
	if(self[\selectedBeat] != index) {
		self[\selectedBeat] = index;
		self.selectValue;
	};
},

selectValue: { |self|
	if(self[\param][\mode] == \track) {
		self.displayValue(
			self[\param][\track]
			[self[\selectedBeat]]
		);
	};
},

syncValue: { |self|
	if(
		(self[\param][\mode] == \track)
		and:
		{ self[\selectedBeat].isNil }
	) {
		self.displayValue(
			self[\param][\track]
			[self[\currentBeat]]
		);
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
		self.syncValue;
	};
},

displayValue: { |self, value|
	if(
		self[\paramDict][\values]
		.includesEqual(value)
	) {
		self[\selector].state(
			self[\paramDict][\values]
			.indexOfEqual(value)
		);
		self[\switch].state(
			self[\paramDict][\values]
			.indexOfEqual(value)
		);
	} {
		self[\selector].desindex;
		// FIX ME: SWITCH
	};
},

updateValueIndex: { |self, index|
	var newTrack, value;
	if(self[\param][\mode] == \value) {
		self[\param].setValueIndex(index);
		if(self[\valueModifiesTrack]) {
			value = self[\param].getValueIndex(index);
			newTrack = Array.fill(
				self[\param][\rhythm][\size],
				{ value }
			);
			self[\param].setTrack(newTrack);
		};
	} {
		newTrack = self[\param][\track].copy;
		if(self[\selectedBeat].isNil) {
			newTrack[self[\currentBeat]] =
			self[\param].getValueIndex(index);
			self[\param].setTrack(newTrack);
		} {
			newTrack[self[\selectedBeat]] =
			self[\param].getValueIndex(index);
			self[\param].setTrack(newTrack);
		};
	};
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\selector].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\switch].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\title].style_(textStyle);
},

//------//
// MISC //

removed: false,
doRemove: { |self|
	if(self[\view].notNil) {
		self[\removed] = true;
		self[\view].free;
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

//---------//
// PROXIES //
state: { |self, newState|
	self[\selector].state(newState);
},

states: { |self, newStates|
	self[\selector].states(newStates);
	self[\switch].states(newStates);
	self[\states] = newStates;
},

orientation: { |self, orientation|
	self[\selector].orientation(orientation);
},
)