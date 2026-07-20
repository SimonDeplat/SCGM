(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(3, 3);
	self[\currentBeat] = 0;
	self[\selectedBeat] = nil;
	self[\valueModifiesTrack] = true;

	self[\title] = ~gmWidgets.getTitle;

	self[\slider] = ~gmWidgets.getMultiSlider
	.connectSignal(
		\_valuesChanged,
		{ |values|
			var newTrack;
			if(self[\param].notNil) {
				if(self[\param][\mode] == \value) {
					self[\param].setValue(values);
				} {
					newTrack = self[\param][\track].copy;
					if(self[\selectedBeat].isNil) {
						newTrack[self[\currentBeat]] = values;
					} {
						newTrack[self[\selectedBeat]] = values;
					};
					self[\param].setTrack(newTrack);
				};
			};
		},
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

	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\menu][\view], 1)
		.add(self[\slider][\view], 3)
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
	self.setName(paramDict[\text]);
	self[\slider].setMin(param[\min]);
	self[\slider].setMax(param[\max]);
	self[\slider].setScale(paramDict[\scale]);
	self.syncValues;

	param.connectSignal(
		\_valueChanged,
		{ self.syncValues; },
		self
	);
	param.connectSignal(
		\_trackChanged,
		{ self.syncValues; },
		self
	);
	param.connectSignal(
		\_minChanged,
		{ |value|
			self[\slider].setMin(value);
		},
		self
	);
	param.connectSignal(
		\_maxChanged,
		{ |value|
			self[\slider].setMax(value);
		},
		self
	);
	param.connectSignal(
		\_modeChanged,
		{ |mode|
			self.syncValues;
			if(mode == \value) {
				self[\modeSwitch].state(0);

			} {
				self[\modeSwitch].state(1);
			};
		},
		self
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
				self.syncValues;
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
					self.syncValues;
				},
				self
			);
		},
		self
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
		self.syncValues;
	};
},

selectBeat: { |self, index|
	if(self[\selectedBeat] != index) {
		self[\selectedBeat] = index;
		self.syncValues;
	};
},

syncValues: { |self|
	if(self[\param][\mode] == \value) {
		self[\slider].setValues(
			self[\param][\value]
		);
	} {
		if(self[\selectedBeat].isNil) {
			self[\slider].setValues(
				self[\param][\track]
				[self[\currentBeat]]
			);
		} {
			self[\slider].setValues(
				self[\param][\track]
				[self[\selectedBeat]]
			);
		};
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
		self.syncValues;
	};
},



//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\slider][\view].style_(widgetStyle);
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
)