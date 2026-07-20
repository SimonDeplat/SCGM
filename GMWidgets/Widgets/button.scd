(
//------//
// CORE //
type: \button,
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMButton()
	.action_({
		self.emitSignal(
			\_buttonPressed
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

svg: { |self, filePath|
	self[\view].svg_(filePath);
	self
},

svgRatio: { |self, ratio|
	self[\view].svgRatio_(ratio);
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