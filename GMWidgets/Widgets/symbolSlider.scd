(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMSymbolSlider()
		.fontRatio_(0.4)
	.maxFontSize_(24)
	.action_({ |value|
		self.emitSignal(\_valueChanged, value);
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
setValue: { |self, value|
	self[\view].value_(value);
	self
},

min: { |self, min|
	self[\view].min_(min);
	self
},

max: { |self, max|
	self[\view].max_(max);
	self
},

scale: { |self, scale|
	self[\view].scale_(scale);
	self
},

expMin: { |self, aNumber|
	self[\view].expMin_(aNumber);
},

orientation: { |self, orientation|
	self[\view].orientation_(orientation);
	self
},

polarity: { |self, polarity|
	self[\view].polarity_(polarity);
	self
},

helpersNumber: { |self, aNumber|
	self[\view].helpersNumber_(aNumber);
},

helpersSubdivisions: { |self, aNumber|
	self[\view].helpersSubdivisions_(aNumber);
},

modStep: { |self, aNumber|
	self[\view].modStep_(aNumber);
},

modStepOperator: { |self, operator|
	self[\view].modStepOperator_(operator);
},

modStepPixelRange: { |self, aNumber|
	self[\view].modStepPixelRange_(aNumber);
},

modStep2: { |self, aNumber|
	self[\view].modStep2_(aNumber);
},

modStep2Operator: { |self, operator|
	self[\view].modStep2Operator_(operator);
},

modStep2PixelRange: { |self, aNumber|
	self[\view].modStep2PixelRange_(aNumber);
},

modSteps: { |self, modSteps|
	self[\view].modSteps_(modSteps);
},

modStepsOperators: { |self, operators|
	self[\view].modStepsOperators_(operators);
},

modStepsPixelRanges: { |self, ranges|
	self[\view].modStepsPixelRanges_(ranges);
},

symbol: { |self, symbol|
	self[\view].symbol_(symbol);
	self
},

symbolMinSize: { |self, pixelSize|
	self[\view].symbolMinSize_(pixelSize);
	self
},

symbolMaxSize: { |self, pixelSize|
	self[\view].symbolMaxSize_(pixelSize);
	self
},

symbolRatio: { |self, ratio|
	self[\view].symbolRatio_(ratio);
	self
},

displayLine: { |self, aSymbol|
	self[\view].displayLine_(aSymbol);
	self
},

displayValue: { |self, boolean|
	self[\view].displayValue_(boolean);
	self
},

centerValue: { |self, boolean|
	self[\view].centerValue_(boolean);
	self
},

roundValue: { |self, aNumber|
	self[\view].roundValue_(aNumber);
	self
},

displayFunction: { |self, aFunction|
	self[\view].displayFunction_(aFunction);
	self
},

fontRatio: { |self, ratio|
	self[\view].fontRatio_(ratio);
	self
},

displayHelpers: { |self, boolean|
	self[\view].displayHelpers_(boolean);
	self
},

helpersRatio: { |self, ratio|
	self[\view].helpersRatio_(ratio);
	self
},

displayFrame: { |self, boolean|
	self[\view].displayFrame_(boolean);
	self
},

setMaxWidth: { |self, width|
	self[\view].maxWidth_(width);
	self
},

getMaxWidth: { |self|
	self[\view].maxWidth
},

setMaxHeight: { |self, height|
	self[\view].maxHeight_(height);
	self
},

getMaxHeight: { |self|
	self[\view].maxHeight
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
	self.emitSignal(\remove);
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},
)