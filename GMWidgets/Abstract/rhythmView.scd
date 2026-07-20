(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(1, 3);

	self[\depthSVGs] = [
		\rDepth0,
		\rDepth1,
		\rDepth2,
		\rDepth3,
		\rDepth4
	];

	self[\currentMulState] = 0;

	self[\depthSwitch] = ~gmWidgets.getSwitch
	.fontRatio(0.8)
	.states([(
		string: "",
		svg: ~gmWidgets.getIcon(\rDepth0)
	)])
	.connectSignal(
		\_stateChanged,
		{ |state|
			var mul;
			if(self[\rhythm].notNil) {
				if(state == 0) {
					mul = [1, 2, 4][self[\currentMulState]];
				} {
					mul =
					self[\rhythm][\player][\divisions][state - 1]
					* [1, 2, 4][self[\currentMulState]];
				};
				self[\rhythm].setDepthMul(state, mul);
			};
		},
		self
	);

	self[\mulSwitch] = ~gmWidgets.getSwitch
	.fontRatio(0.8)
	.states([
		(
			string: "",
			svg: ~gmWidgets.getIcon(\rMul1)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\rMul2)
		),
		(
			string: "",
			svg: ~gmWidgets.getIcon(\rMul4)
		),
	])
	.connectSignal(
		\_stateChanged,
		{ |state|
			var mul;
			self[\currentMulState] = state;
			if(self[\rhythm].notNil) {
				if(self[\rhythm][\depth] == 0) {
					mul = [1, 2, 4][state];
				} {
					mul =
					self[\rhythm][\player][\divisions]
					[self[\rhythm][\depth] - 1]
					* [1, 2, 4][state];
				};
				self[\rhythm].setMul(mul);
			};
		},
		self
	);

	self[\view] = UserView()
	.layout_(
		VLayout()
		.margins_(2)
		.spacing_(2)
		.add(self[\depthSwitch][\view], 1)
		.add(self[\mulSwitch][\view], 1)
	)
	.onClose_({
		if(self[\removed].not) {
			self[\view] = nil;
			self.doRemove;
		};
	});

	self
},

setRhythm: { |self, rhythm|
	var newMul;
	var states = List(0);

	if(self[\rhythm].notNil) {
		self[\rhythm].disconnectNode(self);
	};

	self[\rhythm] = rhythm;

	min(
		self[\rhythm][\player][\divisions].size,
		self[\depthSVGs].size
	).do({ |index|
		states.add(
			(
				string: "",
				svg: ~gmWidgets.getIcon(self[\depthSVGs][index])
			)
		);
	});

	while({
		states.size <
		self[\rhythm][\player][\divisions].size
	}) {
		states.add(
			(
				string: states.size.asString
			)
		);
	};

	self[\depthSwitch]
	.states(states.asArray)
	.state(rhythm[\depth]);

	rhythm.connectSignal(
		\_depthChanged,
		{ |depth|
			self[\depthSwitch].state(depth);
		},
		self
	);

	newMul = rhythm[\mul];
	if(rhythm[\depth] > 0) {
		newMul = newMul / rhythm[\player][\divisions][rhythm[\depth] - 1];
	};

	if([1, 2, 4].includesEqual(newMul)) {
		self[\mulSwitch].state(
			[1, 2, 4].indexOfEqual(newMul);
		);
	};

	rhythm.connectSignal(
		\_mulChanged,
		{ |mul|
			if(rhythm[\depth] > 0) {
				mul = mul / rhythm[\player][\divisions][rhythm[\depth] - 1];
			};

			if([1, 2, 4].includesEqual(mul)) {
				self[\mulSwitch].state(
					[1, 2, 4].indexOfEqual(mul);
				);
			};
		},
		self
	);



	// FIX ME: other muls

	/*self[\depthSwitch]
	.state([1, 2, 4].indexOfEqual(rhythm[\mul]));

	rhythm.connectSignal(
		\_mulChanged,
		{ |mul|
			self[\mulSwitch].state(
				[1, 2, 4].indexOfEqual(mul)
			);
		},
		self
	);*/

	// TO DO: connect \_mulChanged signal
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\depthSwitch].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\mulSwitch].setStyles(
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