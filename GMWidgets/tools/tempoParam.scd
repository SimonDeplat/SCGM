(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(1, 3);
	self[\states] = nil;

	self[\title] = ~gmWidgets.getTitle;
	self[\selector] = ~gmWidgets.getSelector
	.maxFontSize(30);
	self[\switch] = ~gmWidgets.getSwitch
	.maxFontSize(30);
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
	self[\param] = param;
	self.name(paramDict[\text]);
	self[\values] = [8, 4, (1 + (1 / 3)) * 2, 2, (1 + (1 / 3)), 1, 0.5, 0.25];
	self[\states] = ["x8", "x4", "x2.6-", "x2", "x1.3-", "-", "/2", "/4"];
	self[\selector].states(self[\states]);
	self[\switch].states(self[\states]);
	self[\selector].state(self[\values].indexOfEqual(1));
	self[\switch].state(self[\values].indexOfEqual(1));


	self[\selector].connectSignal(
		\_stateChanged, { |index|
			param.setMul(self[\values][index]);
		};
	);
	self[\switch].connectSignal(
		\_stateChanged, { |index|
			param.setMul(self[\values][index]);
		};
	);

	param.connectSignal(
		\_mulChanged, { |value|
			if(
				self[\values]
				.includesEqual(value)
			) {
				self[\selector].state(
					self[\values]
					.indexOfEqual(value)
				);
				self[\switch].state(
					self[\values]
					.indexOfEqual(value)
				);
			} {
				self[\selector].desindex;
				// FIX ME: SWITCH
			};
		};
	);
},

//---------//
// METHODS //
name: { |self, name|
	self[\title].string_(name);
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
	self.emitSignal(\removed);
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},

//-------//
// PROXY //
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