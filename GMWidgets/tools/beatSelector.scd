(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(6, 1);

	self[\currentIndex] = -1;

	self[\selector] = ~gmWidgets.getSelector
	.orientation(\horizontal)
	.states([""])
	.fontRatio(0.5)
	.allowRetrigger(true)
	.desindex
	.connectSignal(
		\_stateChanged,
		{ |index|
			if(index == self[\currentIndex]) {
				self.emitSignal(
					\_beatDeselected
				);
				self[\currentIndex] = -1;
				self[\selector].desindex;
				self[\switch].state(0);
			} {
				self.emitSignal(
					\_beatSelected,
					index
				);
				self[\switch].state(index + 1);
				self[\currentIndex] = index;
			};
		},
		self
	);
	self[\switch] = ~gmWidgets.getSwitch
	.states(["-"])
	.fontRatio(0.7)
	.connectSignal(
		\_stateChanged,
		{ |index|
			if(index == 0) {
				self.emitSignal(
					\_beatDeselected
				);
				self[\currentIndex] = -1;
				self[\selector].desindex;
			} {
				self.emitSignal(
					\_beatSelected,
					index
				);
				self[\currentIndex] = index - 1;
				self[\selector].state(index - 1);
			};
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
		if(self[\rhythm].notNil) {
			if(
				(view.bounds.width / self[\rhythm].size)
				< 24
			) {
				self[\switch][\view].visible_(true);
				self[\selector][\view].visible_(false);
			} {
				self[\switch][\view].visible_(false);
				self[\selector][\view].visible_(true);
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

setRhythm: { |self, rhythm|
	if(self[\rhythm].notNil) {
		self[\rhythm].disconnectNode(self);
	};
	self[\rhythm] = rhythm;
	self.resetView(rhythm[\size]);
	self[\rhythm].connectSignal(
		\_sizeChanged,
		{ self.resetView(rhythm[\size]); },
		self
	);
	self
},

resetView: { |self, size|
	self[\selector].states(
		Array.fill(
			size,
			{ |i| (i + 1).asString }
		);
	);
	self[\selector].desindex;
	self[\selector].setFontColorAll(Color.grey);
	self[\switch].states(
		["-"] ++
		Array.fill(
			size,
			{ |i| (i + 1).asString }
		);
	);
	self[\currentIndex] = -1;
	self.emitSignal(
		\_beatDeselected
	);
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

setVisible: { |self, visible|
	self[\view].visible_(visible);
	self
},

isVisible: { |self|
	self[\view].visible
},

maxWidth: { |self, width|
	self[\view].maxWidth_(width);
	self
},

maxHeight: { |self, height|
	self[\view].maxHeight_(height);
	self
},
)