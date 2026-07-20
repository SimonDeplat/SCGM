(
//------//
// CORE //
init: { |self|

	self[\signals] = ();

	self[\view] = GMSymbol2DSlider()
	.style_(~gmWidgets[\widgetStyle])
	.action_({ |x, y|
		self.emitSignal(\_valuesChanged, Point(x, y));
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
min: { |self, min|
	self[\view].min_(min);
	self
},

max: { |self, max|
	self[\view].max_(max);
	self
},

scales: { |self, scales|
	self[\view].scales_(scales);
	self
},

setValues: { |self, values|
	self[\view].values_(values);
	self
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

displayValues: { |self, boolean|
	self[\view].displayValues_(boolean);
	self
},

roundValues: { |self, roundValues|
	self[\view].roundValues_(roundValues);
	self
},

fontRatio: { |self, ratio|
	self[\view].fontRatio_(ratio);
	self
},

displayLine: { |self, boolean|
	self[\view].displayLine_(boolean);
	self
},

displayHelpers: { |self, boolean|
	self[\view].displayHelpers_(boolean);
	self
},

centerHelpers: { |self, boolean|
	self[\view].centerHelpers_(boolean);
	self
},

helpersStyle: { |self, symbol|
	self[\view].helpersStyle_(symbol);
	self
},

helpersSubdivisions: { |self, subdivisions|
	self[\view].helpersSubdivisions_(subdivisions);
	self
},

helpersRatio: { |self, ratio|
	self[\view].helpersRatio_(ratio);
	self
},

polarities: { |self, polarities|
	self[\view].polarities_(polarities);
	self
},

xDisplayFunction: { |self, function|
	self[\view].xDisplayFunction_(function);
	self
},

yDisplayFunction: { |self, function|
	self[\view].yDisplayFunction_(function);
	self
},

svg: { |self, pathToFile|
	self[\view].svg_(pathToFile);
	self
},

svgRatio: { |self, ratio|
	self[\view].svgRatio_(ratio);
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