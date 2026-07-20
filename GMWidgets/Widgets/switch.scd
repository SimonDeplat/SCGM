(
//------//
// CORE //
type: \switch,
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMSwitchButton()
	.action_({ |index|
		self.emitSignal(
			\_stateChanged,
			index
		);
	})
	.onClose_({
		if(self[\removed].not) {
			self[\view] = nil;
			self.doRemove;
		};
	});

	self
},

//---------//
// PROXIES //
state: { |self, index|
	self[\view].state_(index);
	self
},

states: { |self, newStates|
	self[\view].states_(newStates);
	self
},

maxFontSize: { |self, pixelSize|
	self[\view].maxFontSize_(pixelSize);
	self
},

fontRatio: { |self, ratio|
	self[\view].fontRatio_(ratio);
	self
},

svgRatio: { |self, ratio|
	self[\view].svgRatio_(ratio);
	self
},

direction: { |self, direction|
	self[\view].direction_(direction);
	self
},

setColorAll: { |self, color|
	self[\view].setColorAll(color);
	self
},

setFontColorAll: { |self, color|
	self[\view].setFontColorAll(color);
	self
},

displayFrame: { |self, boolean|
	self[\view].displayFrame_(boolean);
	self
},

visible: { |self, visible|
	self[\view].visible_(visible);
	self
},

maxWidth: { |self, width|
	self[\view].maxWidth_(width);
	self
},

maxHeight: { |self, height|
	self[\view].maxHeight_(height);
	self
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(widgetStyle);
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
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},
)