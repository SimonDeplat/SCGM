(
init: { |self|
	var outs;

	self[\stretch] = 1;

	// Usually true:
	self[\paramSymbol] = \out;
	self[\numChannels] = 2;

	if(~gmDefs.isNil) {
		outs = self.getSCOuts(self[\numChannels]);
	} {
		outs = ~gmDefs[\ioManager]
		.getSCOuts(self[\numChannels]);
	};
	self[\busses] = outs[\busses];
	self[\states] = outs[\names];

	self.initView;

	// var topLayout, bottomLayout;
	/*self[\closeButton] = GMCloseButton()
	.action_({
		self[\synthView][\view]
		.layout.index_(0);
	});*/
	/*self[\effectSelector] = GMMultiButton()
	.orientation_(\vertical);
	self[\masterSelector] = GMMultiButton()
	.orientation_(\vertical);*/
	/*topLayout = HLayout()
	.margins_(0)
	.spacing_(0)
	.add(self[\title], 9)
	.add(self[\closeButton], 1);
	bottomLayout = HLayout()
	.margins_(0)
	.spacing_(0)
	.add(self[\effectSelector], 1)
	.add(self[\masterSelector], 1);
	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(topLayout, 1)
		.add(bottomLayout, 9)
	);*/

	self
},

initView: { |self|

	self[\title] = ~gmWidgets.getTitle
	.string_("out");

	self[\selector] = ~gmWidgets.getSelector
	.states(self[\states].deepCopy)
	.connectSignal(
		\_stateChanged,
		{ |index|
			self[\synth].setParam(
				self[\paramSymbol],
				self[\busses][index]
			);
		}
	);

	self[\switch] = ~gmWidgets.getSwitch
	.states(self[\states].deepCopy)
	.connectSignal(
		\_stateChanged,
		{ |index|
			self[\synth].setParam(
				self[\paramSymbol],
				self[\busses][index]
			);
		}
	);
	self[\switch][\view].visible_(false);

	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(
			HLayout()
			.add(self[\selector][\view], 1)
			.add(self[\switch][\view], 1),
			3
		)
	)
	.onResize_({ |view|
		if(self[\states].notNil) {
			if(view.bounds.height > 128) {
				if((view.bounds.height / self[\states].size) > 32) {
					self[\selector][\view].visible_(true);
					self[\switch][\view].visible_(false);
				} {
					self[\switch][\view].visible_(true);
					self[\selector][\view].visible_(false);
				};
			} {
				if(view.bounds.height > 64) {
					self[\switch][\view].visible_(true);
					self[\selector][\view].visible_(false);
				} {
					self[\switch][\view].visible_(false);
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
},

//-------//
// PROXY //
state: { |self, index|
	self[\selector].state(index);
	self[\switch].state(index);
},

states: { |self, newStates|
	self[\selector].states(newStates.deepCopy);
	self[\switch].states(newStates.deepCopy);
	self[\states] = newStates;
},

orientation: { |self, orientation|
	self[\selector].orientation(orientation);
},

name: { |self, name|
	self[\title].string_(name);
},

removed: false,
doRemove: { |self|
	if(self[\view].notNil) {
		self[\removed] = true;
		self[\view].remove;
	};
	self.emitSignal(\remove);
	self.clear;
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

setSynth: { |self, synth|
	self[\synth] = synth;
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(\remove, self[\synthRMFunction]);
		self[\synthRMFunction] = nil;
		self[\synth] = nil;
	};
},

//------//
// MISC //
updateChannels: { |self, numChannels|
	var outs;

	if(self[\numChannels] != numChannels) {
		self[\numChannels] = numChannels;

		if(~gmDefs.isNil) {
			outs = self.getSCouts(self[\numChannels]);
		} {
			outs = ~gmDefs[\ioManager]
			.getSCOuts(self[\numChannels]);
		};

		self[\busses] = outs[\busses];
		self[\states] = outs[\names];

		self[\selector].states(self[\states].deepCopy);
		self[\switch].states(self[\states].deepCopy);
	};
},

//-----//
// WIP //
setPlayer: { |self, player|
	self.disconnectPlayer;
	self[\player] = player;
	self[\effectFunction] = { self.updateOuts; };
	player.addSignal(\effect, self[\effectFunction]);
	self[\effectFunction].value;
	self[\playerRMFunction] = { self.disconnectPlayer; };
	player.addSignal(\remove, self[\playerRMFunction]);
},

disconnectPlayer: { |self|
	if(self[\player].notNil) {
		self[\player].rmSignal(\effect, self[\effectFunction]);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playerRMFunction] = nil;
		self[\player] = nil;
	};
},

doRemove: { |self|
	self.disconnectPlayer;
	self.disconnectSynth;
	self[\view].remove;
	self.clear;
},

// This provides autonomous connexion to SC busses
// but ~gmDefs should usually override this
// see (gmDefs/protos/ioManager.scd)
getSCOuts: { |self, numChannels|
	var indices, names;
	var numOuts;

	numOuts = s.options.numOutputBusChannels;

	numOuts = numOuts -
	(numOuts % numChannels);
	numOuts = numOuts / numChannels;
	numOuts = numOuts.asInteger;

	indices = List.newClear(numOuts);
	names = List.newClear(numOuts);

	numOuts.do({ |index|
		indices[index] = index * numChannels;
		names[index] =
		"SC out " ++
		(index * self[\numChannels]).asString;
	});

	(
		busses: indices,
		names: names
	)
},
)