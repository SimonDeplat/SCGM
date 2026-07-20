(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(6, 1);

	self[\freqs] = (69..81).midicps;
	self[\noteNames] = [
		"A", "Bb",
		"B",
		"C", "Db",
		"D", "Eb",
		"E",
		"F", "F#",
		"G", "Ab",
		"A"
	];

	self[\selector] = ~gmWidgets.getSelector
	.states(self[\noteNames])
	.connectSignal(
		\_stateChanged,
		{ |index|
			self.emitSignal(
				\_freqChanged,
				self[\freqs][index]
			);
		},
		self
	);
	self[\switch] = ~gmWidgets.getSwitch
	.states(self[\noteNames])
	.connectSignal(
		\_stateChanged,
		{ |index|
			self.emitSignal(
				\_freqChanged,
				self[\freqs][index]
			);
		},
		self
	);
	self[\switch][\view].visible_(false);

	self[\view] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\selector][\view], 1)
		.add(self[\switch][\view], 1)
	)
	.onResize_({ |view|
		var size;

		if(view.bounds.height < view.bounds.width) {
			self[\selector].orientation(\horizontal);
			size = view.bounds.width;
		} {
			self[\selector].orientation(\vertical);
			size = view.bounds.height;
		};

		if(size >= (self[\noteNames].size * 32)) {
			self[\switch][\view].visible_(false);
			self[\selector][\view].visible_(true);
		} {
			self[\switch][\view].visible_(true);
			self[\selector][\view].visible_(false);
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

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\selector][\view].style_(widgetStyle);
	self[\switch][\view].style_(widgetStyle);
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

visible: { |self, visible|
	self[\view].visible_(visible);
	self
},
)