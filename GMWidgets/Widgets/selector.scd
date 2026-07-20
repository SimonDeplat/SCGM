(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMMultiButton()
	.fontRatio_(0.7)
	.orientation_(\vertical)
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

//-------//
// PROXY //
state: { |self, index|
	self[\view].state_(index);
	self
},

states: { |self, newStates|
	self[\view].states_(newStates);
	self
},

getStates: { |self|
	self[\view].states
},

orientation: { |self, orientation|
	self[\view].orientation_(orientation);
	self
},

allowRetrigger: { |self, boolean|
	self[\view].allowRetrigger_(boolean);
	self
},

desindex: { |self|
	self[\view].desindex;
	self
},

direction: { |self, direction|
	self[\view].direction_(direction);
	self
},

fontRatio: { |self, ratio|
	self[\view].fontRatio_(ratio);
	self
},

maxFontSize: { |self, size|
	self[\view].maxFontSize_(size);
	self
},

unselectedRatio: { |self, ratio|
	self[\view].unselectedRatio_(ratio);
	self
},

setColorAll: { |self, color|
	self[\view].setColorAll_(color);
	self
},

setFontColorAll: { |self, color|
	self[\view].setFontColorAll_(color);
	self
},

displayAltValue: { |self, boolean|
	self[\view].displayAltValue_(boolean);
	self
},

svgRatio: { |self, ratio|
	self[\view].svgRatio_(ratio);
	self
},

displayFrame: { |self, boolean|
	self[\view].displayFrame_(boolean);
	self
},

visible: { |self, boolean|
	self[\view].visible_(boolean);
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