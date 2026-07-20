(
// Values are passed as copies
// using Array.newFrom(values)
// to prevent 'pointer updates'

//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMFaderMultiSlider()
	.action_({ |values|
		self.emitSignal(
			\_valuesChanged,
			Array.newFrom(values)
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
setValues: { |self, values|
	self[\view].values_(Array.newFrom(values));
	self
},

setMin: { |self, min|
	self[\view].min_(min);
	self
},

getMin: { |self|
	self[\view].min
},

setMax: { |self, max|
	self[\view].max_(max);
	self
},

getMax: { |self|
	self[\view].max
},

setScale: { |self, scale|
	self[\view].scale_(scale);
	self
},

getScale: { |self|
	self[\view].scale
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
},

getHelpersNumber: { |self|
	self[\view].helpersNumber
},

setHelpersSubdivisions: { |self, aNumber|
	self[\view].helpersSubdivisions_(aNumber);
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

slidersColors: { |self, colors|
	self[\view].slidersColors_(colors);
	self
},

beat: { |self, beat|
	self[\view].beat_(beat);
	self
},

displayHighlights: { |self, highlights|
	self[\view].displayHighlights_(highlights);
	self
},

highlightsRatio: { |self, ratio|
	self[\view].highlightsRatio_(ratio);
	self
},

highlights: { |self, highlights|
	self[\view].highlights_(highlights);
	self
},

setDisplayFunction: { |self, aFunction|
	self[\view].displayFunction_(aFunction);
	self
},

getDisplayFunction: { |self|
	self[\view].displayFunction
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
	self.emitSignal(\_removed);
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},
)