(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMDuoSequencer()
	.style_(~gmWidgets[\widgetStyle])
	.action_({ |values|
		self.emitSignal(
			\_valuesChanged,
			values
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
setValues: { |self, values|
	self[\view].values_(values);
	self
},

probabilities: { |self, values|
	self[\view].probabilities_(values);
	self
},

beat: { |self, beat|
	self[\view].beat_(beat);
	self
},

highlights: { |self, highlights|
	self[\view].highlights_(highlights);
	self
},

displayHighlights: { |self, boolean|
	self[\view].displayHighlights_(boolean);
	self
},

symbol: { |self, symbol|
	self[\view].symbol_(symbol);
	self
},

symbolRatio: { |self, ratio|
	self[\view].symbolRatio_(ratio);
	self
},

displayFrame: { |self, boolean|
	self[\view].displayFrame_(boolean);
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
)