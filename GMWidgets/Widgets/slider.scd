(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMFaderSlider()
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
	self
},

orientation: { |self, orientation|
	self[\view].orientation_(orientation);
	self
},

polarity: { |self, polarity|
	self[\view].polarity_(polarity);
	self
},

setHelpersNumber: { |self, aNumber|
	self[\view].helpersNumber_(aNumber);
	self
},

getHelpersNumber: { |self|
	self[\view].helpersNumber
},

setHelpersSubdivisions: { |self, aNumber|
	self[\view].helpersSubdivisions_(aNumber);
	self
},

getHelpersSubdivisions: { |self|
	self[\view].helpersSubdivisions
},

setModStep: { |self, aNumber|
	self[\view].modStep_(aNumber);
	self
},

getModStep: { |self|
	self[\view].modStep
},

setModStepOperator: { |self, operator|
	self[\view].modStepOperator_(operator);
	self
},

getModStepOperator: { |self, operator|
	self[\view].modStepOperator
},

setModStepPixelRange: { |self, aNumber|
	self[\view].modStepPixelRange_(aNumber);
	self
},

getModStepPixelRange: { |self, aNumber|
	self[\view].modStepPixelRange
},

setModStep2: { |self, aNumber|
	self[\view].modStep2_(aNumber);
	self
},

getModStep2: { |self|
	self[\view].modStep2
},

setModStep2Operator: { |self, operator|
	self[\view].modStep2Operator_(operator);
	self
},

getModStep2Operator: { |self, operator|
	self[\view].modStep2Operator
},

setModStep2PixelRange: { |self, aNumber|
	self[\view].modStep2PixelRange_(aNumber);
	self
},

getModStep2PixelRange: { |self, aNumber|
	self[\view].modStep2PixelRange
},

setModSteps: { |self, modSteps|
	self[\view].modSteps_(modSteps);
	self
},

getModSteps: { |self, modSteps|
	self[\view].modSteps
},

setModStepsOperators: { |self, operators|
	self[\view].modStepsOperators_(operators);
	self
},

getModStepsOperators: { |self|
	self[\view].modStepsOperators
},

setModStepsPixelRanges: { |self, ranges|
	self[\view].modStepsPixelRanges_(ranges);
	self
},

getModStepsPixelRanges: { |self, ranges|
	self[\view].modStepsPixelRanges
},

minAlpha: { |self, minAlpha|
	self[\view].minAlpha_(minAlpha);
	self
},

sliderRatio: { |self, ratio|
	self[\view].sliderRatio_(ratio);
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

setDisplayFunction: { |self, aFunction|
	self[\view].displayFunction_(aFunction);
	self
},

getDisplayFunction: { |self|
	self[\view].displayFunction
},

fontRatio: { |self, ratio|
	self[\view].fontRatio_(ratio);
	self
},

maxFontSize: { |self, pixelSize|
	self[\view].maxFontSize_(pixelSize);
	self
},

setDisplayHelpers: { |self, boolean|
	self[\view].displayHelpers_(boolean);
	self
},

getDisplayHelpers: { |self|
	self[\view].displayHelpers
},

setHelpersStyle: { |self, symbol|
	self[\view].helpersStyle_(symbol);
	self
},

getHelpersStyle: { |self|
	self[\view].helpersStyle
},

setHelpersRatio: { |self, ratio|
	self[\view].helpersRatio_(ratio);
	self
},

getHelpersRatio: { |self|
	self[\view].helpersRatio
},

setCenterHelpers: { |self, boolean|
	self[\view].centerHelpers_(boolean);
	self
},

getCenterHelpers: { |self|
	self[\view].centerHelpers
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
	self.emitSignal(\remove);
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},
)