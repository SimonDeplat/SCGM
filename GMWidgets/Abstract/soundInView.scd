(
init: { |self|
	var ins;

	self[\stretch] = 1;

	self[\paramSymbol] = \soundIn;
	self[\numChannels] = 1;

	if(~gmDefs.isNil) {
		ins = self.getSCIns(self[\numChannels]);
	} {
		ins = ~gmDefs[\ioManager]
		.getSCIns(self[\numChannels]);
	};
	self[\busses] = ins[\busses];
	self[\names] = ins[\names];

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

updateChannels: { |self, numChannels|
	var ins;

	if(self[\numChannels] != numChannels) {
		self[\numChannels] = numChannels;

		if(~gmDefs.isNil) {
			ins = self.getSCIns(self[\numChannels]);
		} {
			ins = ~gmDefs[\ioManager]
			.getSCIns(self[\numChannels]);
		};

		self[\busses] = ins[\busses];
		self[\names] = ins[\names];

		self[\selector].states(self[\names]);
	};
},

initView: { |self|
	self[\title] = GMTextView()
	.string_("out")
	.displayFrame_(true)
	.maxHeight_(~gmWidgets[\textboxMaxSize]);

	self[\selector] = ~gmWidgets.getSelector
	.states(self[\names])
	.connectSignal(
		\_stateChanged,
		{ |index|
			self[\synth].setParam(
				self[\paramSymbol],
				self[\busses][index]
			);
		}
	);

	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\selector][\view], 3)
	)
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
},

states: { |self, newStates|
	self[\selector].states(newStates);
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
	self[\selector].setStyles_(
		style,
		textStyle,
		widgetStyle
	);
	self[\title].style_(textStyle);
},

setSynth: { |self, synth|
	self.disconnectSynth;
	self[\synth] = synth;
	self[\synthRMFunction] = { self.disconnectSynth; };
	synth.connectSignal(\remove, self[\synthRMFunction]);
},

disconnectSynth: { |self|
	if(self[\synth].notNil) {
		self[\synth].rmSignal(\remove, self[\synthRMFunction]);
		self[\synthRMFunction] = nil;
		self[\synth] = nil;
	};
},

//-----//
// WIP //
//-----//

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
getSCIns: { |self, numChannels|
	var indices, names;
	var numIns;

	numIns = s.options.numInputBusChannels;

	numIns = numIns -
	(numIns % numChannels);
	numIns = numIns / numChannels;
	numIns = numIns.asInteger;

	indices = List.newClear(numIns);
	names = List.newClear(numIns);

	numIns.do({ |index|
		indices[index] = index * numChannels;
		names[index] =
		"SC in " ++
		(index * self[\numChannels]).asString;
	});

	(
		busses: indices,
		names: names
	)
},
)