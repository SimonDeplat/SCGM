(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMCurveEnvView()
	.action_({ |env|
		self.emitSignal(\_envChanged, env);
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
env: { |self, env|
	self[\view].env_(env);
	self
},

getEnv: { |self|
	self[\view].env
},

setTimeScale: { |self, scale|
	self[\view].timeScale_(scale);
	self
},

getTimeScale: { |self|
	self[\view].timeScale
},

yMin: { |self, min|
	self[\view].yMin_(min);
	self
},

yMax: { |self, max|
	self[\view].yMax_(max);
	self
},

lastLevelIsZero: { |self, boolean|
	self[\view].lastLevelIsZero_(boolean);
	self
},

maxSize: { |self, maxSize|
	self[\view].maxSize_(maxSize);
	self
},

modColor: { |self, color|
	self[\view].modColor_(color);
	self
},

displayHelpers: { |self, boolean|
	self[\view].displayHelpers_(boolean);
	self
},

setDisplayTimeHelpers: { |self, boolean|
	self[\view].displayTimeHelpers_(boolean);
	self
},

getDisplayTimeHelpers: { |self|
	self[\view].displayTimeHelpers
},

setHelpersTime: { |self, time|
	self[\view].helpersTime_(time);
	self
},

getHelpersTime: { |self|
	self[\view].helpersTime
},

setTimeHelpersAlpha: { |self, alphas|
	self[\view].timeHelpersAlpha_(alphas);
	self
},

getTimeHelpersAlpha: { |self|
	self[\view].timeHelpersAlpha
},

yHelpers: { |self, anInteger|
	self[\view].yHelpers_(anInteger);
	self
},

helpersWidth: { |self, pixelSize|
	self[\view].helpersWidth_(pixelSize);
	self
},

helpersFontSize: { |self, pixelSize|
	self[\view].helpersFontSize_(pixelSize);
	self
},

yRoundValue: { |self, aNumber|
	self[\view].yRoundValue_(aNumber);
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
)