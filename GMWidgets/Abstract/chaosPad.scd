(
init: { |self|

	self[\signals] = ();

	self.initView;

	self
},

//--------//
//  VIEW  //
initView: { |self|
	self[\stretch] = Point(2, 1);

	self[\title] = GMTextView()
	.style_(~gmWidgets[\textStyle])
	.displayFrame_(true)
	.maxHeight_(~gmWidgets[\textboxMaxSize]);

	self[\slider2D] = ~gmWidgets.getSlider2D
	.min([0, 0])
	.max([1, 1])
	.displayHelpers(true)
	.setValues([0, 0])
	.connectSignal(
		\_valuesChanged, { |values|
			self.slider2DAction(values);
		}
	);

	self[\view] = UserView()
	.acceptsMouseOver_(true)
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\title], 1)
		.add(self[\slider2D][\view], 9)
	);
},

name: { |self, name|
	self[\title].string_(name);
},

slider2DAction: { |self, values|
	if(self[\synth].notNil) {
		self[\synth].setParam(
			self[\paramA],
			values.x
		);
		self[\synth].setParam(
			self[\paramB],
			values.y
		);
	};
},

setSynthAndParams: { |self, synth, paramA, paramB|

	// FIX ME: CONTINUOUS SAFETY CHECK

	// GMDef format needed here
	var paramDictA, paramDictB;

	paramDictA = ~gmDefs[\gmDefs]
	[synth[\name].asSymbol]
	[\params][paramA];

	paramDictB = ~gmDefs[\gmDefs]
	[synth[\name].asSymbol]
	[\params][paramB];

	self[\synth] = synth;

	self[\paramA] = paramA;

	self[\paramB] = paramB;

	self[\slider2D].min([
		synth[\params][paramA][\min],
		synth[\params][paramB][\min]
	]);

	self[\slider2D].max([
		synth[\params][paramA][\max],
		synth[\params][paramB][\max]
	]);

	self[\slider2D].scales([
		paramDictA[\scale],
		paramDictB[\scale]
	]);

	self[\slider2D].setValues([
		synth[\params][paramA][\value],
		synth[\params][paramB][\value]
	]);

	self.name(synth[\name]);

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
	self[\slider2D].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\title].style_(textStyle);
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

//-------//
// PROXY //
min: { |self, min|
	self[\slider2D].min(min);
	self
},

max: { |self, max|
	self[\slider2D].max(max);
	self
},

scales: { |self, scales|
	self[\slider2D].scales(scales);
	self
},

setValues: { |self, values|
	self[\slider2D].values(values);
	self
},

symbol: { |self, symbol|
	self[\slider2D].symbol(symbol);
	self
},

symbolMinSize: { |self, pixelSize|
	self[\slider2D].symbolMinSize(pixelSize);
	self
},

symbolMaxSize: { |self, pixelSize|
	self[\slider2D].symbolMaxSize(pixelSize);
	self
},

symbolRatio: { |self, ratio|
	self[\slider2D].symbolRatio(ratio);
	self
},

displayValues: { |self, boolean|
	self[\slider2D].displayValues(boolean);
	self
},

roundValues: { |self, roundValues|
	self[\slider2D].roundValues(roundValues);
	self
},

fontRatio: { |self, ratio|
	self[\slider2D].fontRatio(ratio);
	self
},

displayLine: { |self, boolean|
	self[\view].displayLine(boolean);
	self
},

displayHelpers: { |self, boolean|
	self[\slider2D].displayHelpers(boolean);
	self
},

centerHelpers: { |self, boolean|
	self[\slider2D].centerHelpers(boolean);
	self
},

helpersStyle: { |self, symbol|
	self[\slider2D].helpersStyle(symbol);
	self
},

helpersSubdivisions: { |self, subdivisions|
	self[\slider2D].helpersSubdivisions(subdivisions);
	self
},

helpersRatio: { |self, ratio|
	self[\slider2D].helpersRatio(ratio);
	self
},

polarities: { |self, polarities|
	self[\slider2D].polarities(polarities);
	self
},

xDisplayFunction: { |self, function|
	self[\slider2D].xDisplayFunction(function);
	self
},

yDisplayFunction: { |self, function|
	self[\slider2D].yDisplayFunction(function);
	self
},

svg: { |self, pathToFile|
	self[\slider2D].svg(pathToFile);
	self
},

svgRatio: { |self, ratio|
	self[\slider2D].svgRatio(ratio);
	self
},
)