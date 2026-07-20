(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(1, 3);

	self[\container] = UserView()
	.layout_(StackLayout());

	self[\title] = ~gmWidgets.getTitle;

	self[\slider] = ~gmWidgets.getSlider
	.connectSignal(
		\_valueChanged,
		{ |value|
			if(self[\param].notNil) {
				self[\param].setValue(value);
			};
		},
		self
	);

	self[\trackSlider] = ~gmWidgets.getMultiSlider
	.beat(0)
	.displayHighlights(true)
	.connectSignal(
		\_valuesChanged,
		{ |values|
			if(self[\param].notNil) {
				self[\param].setTrack(values);
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

	self[\randomButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\random))
	.connectSignal(
		\_buttonPressed,
		{ self[\param].randomize; },
		self
	);

	self[\resetButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\reset))
	.connectSignal(
		\_buttonPressed,
		{ self[\param].doReset; },
		self
	);

	self[\hideButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\hide))
	.connectSignal(
		\_buttonPressed,
		{
			self[\view].visible_(false);
			self.emitSignal(
				\_visible,
				false
			);
		},
		self
	);

	// VIEW
	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\menu][\view], 1)
		.add(self[\container], 3)
	)
	.onResize_({ |view|
		if(view.bounds.height > 32) {
			self[\container].visible_(true);
		} {
			self[\container].visible_(false);
		};
	})
	.onClose_({
		if(self[\removed].not) {
			self[\view] = nil;
			self.doRemove;
		};
	});

	self[\container]
	.layout
	.add(self[\slider][\view])
	.add(self[\trackSlider][\view]);

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
	self.name(paramDict[\text]);

	// Slider setup
	self[\slider]
	.min(param[\min])
	.max(param[\max])
	.scale(paramDict[\scale])
	.setValue(param[\value]);

	param.connectSignal(
		\_valueChanged,
		{ |value|
			self[\slider].setValue(value);
		},
		self
	);

	// Multislider setup
	self[\trackSlider]
	.setMin(param[\min])
	.setMax(param[\max])
	.setScale(paramDict[\scale])
	.setValues(param[\track]);

	self[\param].connectSignal(
		\_trackChanged,
		{ |track|
			self[\trackSlider].setValues(track);
		},
		self
	);

	if(param[\mode] == \value) {
		self[\slider].visible(true);
		self[\trackSlider].visible(false);
		self[\stretch] = Point(1, 3);
	} {
		self[\slider].visible(false);
		self[\trackSlider].visible(true);
		self[\stretch] = Point(3, 3);
	};

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
				// FIX ME: OFFSET
				self[\trackSlider].beat(0);
			},
			self
		);
		self[\trackSlider].highlights(
			self[\rhythm][\highlights]
		);
		self[\rhythm].connectSignal(
			\_highlights,
			{ |highlights|
				self[\trackSlider].highlights(
					self[\rhythm][\highlights]
				);
			},
			self
		);
	};

	param.connectSignal(
		\_rhythmChanged,
		{ |rhythm|
			if(self[\rhythm].notNil) {
				if(self[\rhythm][\player] != rhythm[\player]) {
					self[\rhythm][\player].disconnectNode(self);
				};
				self[\rhythm].disconnectNode(self);
			};
			rhythm[\player].connectSignal(
				\_postBeat,
				{ |beat|
					self.displayBeat(beat);
				},
				self
			);
			rhythm[\player].connectSignal(
				\_stopped,
				{ self[\trackSlider].beat(0); },
				self
			);
			rhythm.connectSignal(
				\_highlights,
				{ |highlights|
					self[\trackSlider].highlights(rhythm[\highlights]);
				},
				self
			);
			self[\rhythm] = rhythm;
		},
		self
	);

	param.connectSignal(
		\_minChanged,
		{ |value|
			self[\slider].min(value);
			self[\trackSlider].min(value);
		},
		self
	);

	param.connectSignal(
		\_maxChanged,
		{ |value|
			self[\slider].max(value);
			self[\trackSlider].setMax(value);
		},
		self
	);

	param.connectSignal(
		\_modeChanged,
		{ |mode|
			switch(mode)
			{ \value } {
				self[\container].layout.index_(0);
				self[\stretch] = Point(1, 3);
			}
			{ \track } {
				self[\container].layout.index_(1);
				self[\stretch] = Point(3, 3);
			};
			self.emitSignal(
				\_stretchChanged,
				self[\stretch]
			);
		},
		self
	);

	self.updateApparence(param[\paramDict]);

	self
},

//---------//
// METHODS //
name: { |self, name|
	self[\title].string_(name);
},

updateApparence: { |self, paramDict|
	self[\slider].setDisplayFunction(
		paramDict[\displayFunction]
	);

	self[\trackSlider].setDisplayFunction(
		paramDict[\displayFunction]
	);

	if(paramDict[\helpersNumber].notNil) {
		self[\slider].setHelpersNumber(
			paramDict[\helpersNumber]
		);
		self[\trackSlider].setHelpersNumber(
			paramDict[\helpersNumber]
		);
	} {
		self[\slider].setHelpersNumber(
			0
		);
		self[\trackSlider].setHelpersNumber(
			0
		);
	};

	if(paramDict[\helpersSubdivisions].notNil) {
		self[\slider].setHelpersSubdivions(
			paramDict[\helpersSubdivisions]
		);
		self[\trackSlider].setHelpersSubdivions(
			paramDict[\helpersSubdivisions]
		);
	} {
		self[\slider].setHelpersSubdivions(0);
		self[\trackSlider].setHelpersSubdivions(0);
	};

	if(
		paramDict[\displayHelpers].notNil
		and:
		{ paramDict[\displayHelpers] }
	) {
		self[\slider].setDisplayHelpers(true);
	} {
		self[\slider].setDisplayHelpers(false);
	};

	if(
		paramDict[\multiSliderDisplayHelpers].notNil
		and:
		{ paramDict[\multiSliderDisplayHelpers] }
	) {
		self[\trackSlider].setDisplayHelpers(true);
	} {
		self[\trackSlider].setDisplayHelpers(false);
	};

	if(paramDict[\helpersStyle].notNil) {
		self[\slider].setHelpersStyle(
			paramDict[\helpersStyle]
		);
		self[\trackSlider].setHelpersStyle(
			paramDict[\helpersStyle]
		);
	} {
		self[\slider].setHelpersStyle(\line);
		self[\trackSlider].setHelpersStyle(\line);
	};

	if(paramDict[\centerHelpers].notNil) {
		self[\slider].setCenterHelpers(
			paramDict[\centerHelpers]
		);
		self[\trackSlider].setCenterHelpers(
			paramDict[\centerHelpers]
		);
	} {
		self[\slider].setCenterHelpers(false);
		self[\trackSlider].setCenterHelpers(false);
	};

	if(paramDict[\helpersRatio].notNil) {
		self[\slider].setHelpersRatio(
			paramDict[\helpersRatio]
		);
		self[\trackSlider].setHelpersRatio(
			paramDict[\helpersRatio]
		);
	} {
		self[\slider].setHelpersRatio(0.5);
		self[\trackSlider].setHelpersRatio(1);
	};

	if(paramDict[\modStep].notNil) {
		self[\slider].setModStep(
			paramDict[\modStep]
		);
		self[\trackSlider].setModStep(
			paramDict[\modStep]
		);
	};

	if(paramDict[\modStepOperator].notNil) {
		self[\slider].setModStepOperator(
			paramDict[\modStepOperator]
		);
		self[\trackSlider].setModStepOperator(
			paramDict[\modStepOperator]
		);
	};

	if(paramDict[\modStep2].notNil) {
		self[\slider].setModStep2(
			paramDict[\modStep2]
		);
		self[\trackSlider].setModStep2(
			paramDict[\modStep2]
		);
	};

	if(paramDict[\modStep2Operator].notNil) {
		self[\slider].setModStep2Operator(
			paramDict[\modStep2Operator]
		);
		self[\trackSlider].setModStep2Operator(
			paramDict[\modStep2Operator]
		);
	};
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\styles] = [
		style,
		textStyle,
		widgetStyle
	];
	self[\title].style_(textStyle);
	self[\slider].setStyles(
		style, textStyle, widgetStyle
	);
	if(self[\trackSlider].notNil) {
		self[\trackSlider].setStyles(
			style, textStyle, widgetStyle
		);
	};
	self[\menu].setStyles(
		style, textStyle, widgetStyle
	);
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
		self[\trackSlider].beat(
			(beat[\absGrid][self[\rhythm][\depth]] - 1)
			+ self[\rhythm][\offset]
			% self[\param][\track].size
		);
	};
},

//------//
// MISC //
displayMenu: { |self, visible|
	self[\menu].visible(visible);
	self
},

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
min: { |self, min|
	self[\slider].min(min);
},

max: { |self, max|
	self[\slider].max(max);
},

scale: { |self, scale|
	self[\slider].scale(scale);
},

setValue: { |self, value|
	self[\slider].setValue(value);
},
)