(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\scales] = [
		\minor,
		\major,
		\dorian,
		\mixolydian,
		\lydian,
		\phrygian,
		\chromatic,
	];

	self[\scaleNames] = [
		"Minor",
		"Major",
		"Dorian",
		"Mixolydian",
		"Phrygian",
		"Lydian",
		"Chromatic",
	];

	self[\rhythms] = [
		[4, 4, 4, 4],
		[4, 2, 6, 2],
		[4, 2, 9, 2],
		[4, 3, 4, 2],
	].asList;

	self.initView;

	self
},

//--------//
//  VIEW  //
initView: { |self|
	self[\stretch] = Point(3, 1);

	self[\title] = ~gmWidgets.getTitle
	.maxHeight_(64)
	.string_("player");

	self.initPlayStopButton;
	self.initTapTempo;
	self.initNoteSelector;
	self.initScaleSelector;
	self.initRhythmSwitch;

	self[\view] = UserView()
	.acceptsMouseOver_(true)
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(0)
			.add(self[\noteSelector][\view], 5)
			.add(self[\scaleSelector][\view], 1),
			2
		)
		.add(
			HLayout()
			.margins_(0)
			.spacing_(0)
			.add(self[\playStopButton][\view], 1)
			.add(self[\tapTempo][\view], 5)
			.add(self[\rhythmSwitch][\view], 1),
			2
		)
	);

	self.setStyles(
		~gmWidgets[\style],
		~gmWidgets[\textStyle],
		~gmWidgets[\widgetStyle]
	);
},

name: { |self, name|
	self[\title].string_(name);
	self
},

initPlayStopButton: { |self|
	self[\playStopButton] = ~gmWidgets.getPlayStopButton
	.setMaxWidth(256);
},

initTapTempo: { |self|
	self[\tapTempo] = ~gmWidgets.getTapTempo
	.connectSignal(
		\_bpmChanged,
		{ |bpm|
			self[\player].setBPM(bpm);
		},
		self
	);
},

initNoteSelector: { |self|
	self[\noteSelector] = ~gmWidgets.getNoteSelector
	.connectSignal(
		\_freqChanged,
		{ |freq|
			self[\player].setFreq(freq);
		},
		self
	);
},

initScaleSelector: { |self|
	self[\scaleSelector] = ~gmWidgets.getSwitch
	.states(self[\scaleNames])
	.connectSignal(
		\_stateChanged,
		{ |index|
			if(self[\player].notNil) {
				self[\player].setScale(
					self[\scales][index]
				);
			};
		},
		self
	);
},

initRhythmSwitch: { |self|
	self[\rhythmSwitch] = ~gmWidgets.getSwitch
	.states(
		self[\rhythms].collect({ |item|
			item.asString
		})
	)
	.connectSignal(
		\_stateChanged,
		{ |index|
			if(self[\player].notNil) {
				self[\player].setRhythm(
					self[\rhythms][index]
				);
			};
		},
		self
	);
},

//--------//
// PLAYER //

connectPlayer: { |self, player|

	self[\player] = player;

	self[\playStopButton].setPlaying(
		player[\isPlaying]
	);

	self[\tapTempo].bpm(
		player[\bpm]
	);

	self[\playStopButton].connectPlayer(player);

	player.connectSignal(
		\_bpmChanged,
		{ |bpm|
			self[\tapTempo].bpm(bpm);
		},
		self
	);

	player.connectSignal(
		\_beat,
		{ |beat|
			if(
				( beat[\beatDetection][0] == 1 )
				or:
				{ beat[\beatDetection][1] == 1 }
			) {
				self[\tapTempo].blink;
			};
		},
		self
	);

	player.connectSignal(
		\_scaleChanged,
		{ |scale|
			self.updateScale(scale);
		},
		self
	);
	self.updateScale(player[\scale]);

	self.updateRhythms;
	player.connectSignal(
		\_rhythmChanged,
		{ self.updateRhythms; },
		self
	);

	self
},

updateRhythms: { |self|
	if(self[\player].notNil) {
		if(self[\rhythms].includesEqual(self[\player][\divisions]).not) {
			self[\rhythms].add(self[\player][\divisions]);
			self[\rhythmSwitch].states(
				self[\rhythms].collect({ |item|
					item.asString
				})
			);
		};
		self[\rhythmSwitch].state(
			self[\rhythms].indexOfEqual(self[\player][\divisions])
		);
	};
},

updateScale: { |self, scale|
	var scaleName = ~gmDefs.getScaleName(scale);
	if(
		self[\scaleNames]
		.includesEqual(scaleName).not
	) {
		self[\scales].add(scale);
		self[\scaleNames].add(scaleName);
		self[\scaleSelector].states(
			self[\scaleNames]
		);
	};
	self[\scaleSelector].state(
		self[\scaleNames].indexOfEqual(scaleName)
	);
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\title].style_(widgetStyle);
	self[\playStopButton].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\tapTempo].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\noteSelector].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self
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
	var window = Window(
		self[\name],
		Rect(
			200, 200,
			300, 150
		)
	)
	.acceptsMouseOver_(true)
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\view])
	)
	.front;
	CmdPeriod.doOnce({
		window.close;
		self.doRemove;
	});
	self
},
)