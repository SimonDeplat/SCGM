(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMListPianoRoll()
	.style_(~gmWidgets[\widgetStyle])
	.actionMode_(\index)
	.action_({ |index, values|
		self.emitSignal(
			\_scoreChanged,
			(index: index, values: values)
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

entries: { |self, entries|
	self[\view].entries_(entries);
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

vHighlights: { |self, highlights|
	self[\view].vHighlights_(highlights);
	self
},

displayVHighlights: { |self, boolean|
	self[\view].displayVHighlights_(boolean);
	self
},

gridColor: { |self, color|
	self[\view].gridColor_(color);
	self
},

gridWidth: { |self, pixelSize|
	self[\view].gridWidth_(pixelSize);
	self
},

boxRatio: { |self, ratio|
	self[\view].boxRatio_(ratio);
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
	self.emitSignal(\_removed);
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},
)