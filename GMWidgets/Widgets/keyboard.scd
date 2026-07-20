(
//------//
// CORE //
init: { |self|

	self[\signals] = ();

	self[\view] = GMKeyboard()
	.action_({ |midiNote, pressed = nil|
		self.emitSignal(
			\_keyPressed,
			[
				midiNote,
				pressed
			]
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
sustainMode: { |self, sustainMode|
	self[\view].sustainMode_(sustainMode);
	self
},

keyNumber: { |self, keyNumber|
	self[\view].keyNumber_(keyNumber);
	self
},

mode: { |self, mode|
	self[\view].mode_(mode);
	self
},

chromaticStartNote: { |self, startNote|
	self[\view].chromaticStartNote_(startNote);
	self
},

displayNames: { |self, displayNames|
	self[\view].displayNames_(displayNames);
	self
},

chromaticStartNote: { |self, startNote|
	self[\view].chromaticStartNote_(startNote);
	self
},

displayHighlights: { |self, displayHighlights|
	self[\view].displayHighlights_(displayHighlights);
	self
},

highlights: { |self, highlights|
	self[\view].highlights_(highlights);
	self
},

keyColor: { |self, color|
	self[\view].keyColor_(color);
	self
},

keyOutlineColor: { |self, color|
	self[\view].keyOutlineColor_(color);
	self
},

blackKeyColor: { |self, color|
	self[\view].blackKeyColor_(color);
	self
},

blackKeyOutlineColor: { |self, color|
	self[\view].blackKeyOutlineColor_(color);
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

fontRatio: { |self, ratio|
	self[\view].fontRatio_(ratio);
	self
},

outlineKeys: { |self, outlineKeys|
	self[\view].outlineKeys_(outlineKeys);
	self
},

blackKeyRatio: { |self, ratio|
	self[\view].blackKeyRatio_(ratio);
	self
},

margins: { |self, margins|
	self[\view].margins_(margins);
	self
},

playKey: { |self, key|
	self[\view].playKey_(key, false);
	self
},

sustainKey: { |self, key|
	self[\view].sustainKey_(key, false);
	self
},

releaseKey: { |self, key|
	self[\view].releaseKey_(key, false);
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