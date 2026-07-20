(
//------//
// CORE //
init: { |self|

	self[\signals] = ();

	self[\view] = GMTapTempo()
	.action_({ |bpm|
		if(bpm.notNil) {
			self.emitSignal(
				\_bpmChanged,
				bpm
			);
		};
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
bpm: { |self, bpm|
	self[\view].bpm_(bpm);
	self
},

blink: { |self|
	self[\view].blink;
	self
},

blinkColor: { |self, color|
	self[\view].blinkColor_(color);
	self
},

blinkFontColor: { |self, color|
	self[\view].blinkFontColor_(color);
	self
},

stringRatio: { |self, ratio|
	self[\view].stringRatio_(ratio);
	self
},

displayFrame: { |self, boolean|
	self[\view].displayFrame_(boolean);
	self
},

//---------//
// SIGNALS //
emitSignal: { |self, symbol, args = nil|
	if(self[\signals].includesKey(symbol)) {
		if(args.isNil) {
			self[\signals][symbol].value;
		} {
			self[\signals][symbol].value(args);
		};
	};
},

connectSignal: { |self, symbol, function|
	if(self[\signals][symbol].isNil) {
		self[\signals][symbol] = FunctionList();
	};
	self[\signals][symbol].addFunc(function);
	self
},

disconnectSignal: { |self, symbol, function|
	if(self[\signals].includesKey(symbol)) {
		self[\signals][symbol].removeFunc(function);
	};
},

clearSignal: { |self, symbol|
	self[\signals].removeAt(symbol);
},

clearAllSignals: { |self|
	self[\signals].clear;
	self[\signals] = ();
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