(
//------//
// CORE //
type: \text,
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMTextView()
	.displayFrame_(true);

	self
},

//-------//
// PROXY //
string: { |self, string|
	self[\view].string_(string);
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

orientation: { |self, orientation|
	self[\view].orientation_(orientation);
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
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},
)