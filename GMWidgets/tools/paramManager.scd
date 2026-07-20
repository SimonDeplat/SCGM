(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(1, 3);

	self[\paramViews] = ();

	// Params by type
	self[\paramsByType] = (
		continuous: List(0),
		multiContinuous: List(0),
		discrete: List(0),
		env: List(0),
		tempo: List(0),
		out: List(0),
		soundIn: List(0),
		buffer: List(0),
	);
	// & associated Views
	self[\soundInWidgets] = List(0);
	self[\continuousWidgets] = List(0);
	self[\multiContinuousWidgets] = List(0);
	self[\selectorWidgets] = List(0);
	self[\envWidgets] = List(0);
	self[\tempoWidgets] = List(0);
	self[\outWidgets] = List(0);

	// Views
	self[\view] = UserView()
	.acceptsMouseOver_(true);

	self[\paramView] = UserView()
	.background_(Color(0.1, 0.1, 0.1))
	.acceptsMouseOver_(true)
	.layout_(
		HLayout()
		.margins_(0)
	);

	self[\stackLayout] = UserView()
	.layout_(
		StackLayout()
		.margins_(0)
		.add(self[\paramView]);
	);

	self[\view].layout_(
		VLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\stackLayout], 1)
	);

	self
},

//-------//
// SYNTH //
setSynth: { |self, synth|
	var paramDict;
	var metaWidget;

	var continuousIndex = 0;
	var multiContinuousIndex = 0;
	var discreteIndex = 0;
	var slider2Index = 0;
	var envIndex = 0;
	var tempoIndex = 0;

	var outIndex = 0;
	var inIndex = 0;
	var soundInIndex = 0;

	var newLayout = HLayout()
	.margins_(0)
	.spacing_(~gmWidgets[\widgetSpacing]);
	self[\synth] = synth;

	self[\widgetsBySymbol] = ();
	self[\stretch].x = 0;

	self[\paramViews] = ();

	// Associate each param to a widget:
	self[\synth][\params].do({ |param|

		// This is needed to reference the widget
		// within signals
		var widget;

		// GMDef format needed here
		paramDict = ~gmDefs[\gmDefs]
		[synth[\name].asSymbol]
		[\params][param[\symbol]];


		switch(param[\type])

		{ \soundIn } {
			metaWidget = self[\soundInWidgets][soundInIndex];
			paramDict[\texts] = param[\values].collect({ |v| v.asString });
			metaWidget.setParam(param, paramDict);
			soundInIndex = soundInIndex + 1;
		}

		{ \discrete } {
			metaWidget = self[\selectorWidgets][discreteIndex];
			metaWidget.setParam(param, paramDict);
			discreteIndex = discreteIndex + 1;
		}

		{ \continuous } {
			widget = self[\continuousWidgets][continuousIndex];
			metaWidget = widget;
			metaWidget.setParam(param, paramDict);
			continuousIndex = continuousIndex + 1;
			metaWidget.connectSignal(
				\_stretchChanged,
				{ |stretch|
					self[\paramView]
					.layout
					.setStretch(
						widget[\view],
						stretch.x
					);
				},
				self
			);
		}

		{ \multiContinuous } {
			metaWidget = self[\multiContinuousWidgets][multiContinuousIndex];
			metaWidget.setParam(param, paramDict);
			multiContinuousIndex = multiContinuousIndex + 1;
		}

		{ \env } {
			metaWidget = self[\envWidgets][envIndex];
			metaWidget.setParam(param, paramDict);
			envIndex = envIndex + 1;
		}

		{ \tempoRate } {
			metaWidget = self[\tempoWidgets][tempoIndex];
			metaWidget.setParam(param, paramDict);
			tempoIndex = tempoIndex + 1;
		}

		{ \tempoDur } {
			metaWidget = self[\tempoWidgets][tempoIndex];
			metaWidget.setParam(param, paramDict);
			tempoIndex = tempoIndex + 1;
		}

		{ \out } {
			metaWidget = self[\outWidgets][outIndex];
			paramDict[\texts] = param[\values].collect({ |v| v.asString });
			metaWidget.setParam(param, paramDict);
			outIndex = outIndex + 1;
		}

		{ \in } {
			metaWidget = nil;
		}

		{ \buffer } {
			metaWidget = nil;
		};

		if(metaWidget.notNil) {
			self[\widgetsBySymbol][param[\symbol]] = metaWidget;
			self[\stretch].x
			= self[\stretch].x + metaWidget[\stretch].x;
			newLayout.add(metaWidget[\view], metaWidget[\stretch].x);

			// Register param
			self[\paramViews][paramDict[\symbol]] = metaWidget;
		};
	});

	self[\paramView].layout.destroy;
	self[\paramView].layout_(newLayout);
	self.emitSignal(\_stretch, self[\stretch]);
},

// This ensures the param manager
// has enough of each views (selector, env, etc)
adaptToSynth: { |self, synth|
	var view;

	self[\paramsByIndex] = List(0);

	// Reference params,
	// sort them by type
	synth[\paramsByIndex].do({ |param|
		if(param[\type] != \in) {
			if(
				(param[\type] == \tempoDur)
				or: { param[\type] == \tempoRate }
			) {
				self[\paramsByIndex].add(param);
				self[\paramsByType][\tempo]
				.add(param);
			} {
				self[\paramsByIndex].add(param);
				self[\paramsByType][param[\type]]
				.add(param);
			};
		};
	});

	// Add enough widgets for each type
	while { (
		self[\soundInWidgets].size
		< self[\paramsByType][\soundIn].size
	) } {
		view = ~gmWidgets.getDiscreteParam;
		self[\soundInWidgets].add(view);
		self.setupView(view);
	};

	while { (
		self[\selectorWidgets].size
		< self[\paramsByType][\discrete].size
	) } {
		view = ~gmWidgets.getDiscreteParam;
		self[\selectorWidgets].add(view);
		self.setupView(view);
	};

	while { (
		self[\continuousWidgets].size
		< self[\paramsByType][\continuous].size
	) } {
		view = ~gmWidgets.getContinuousParam;
		self[\continuousWidgets].add(view);
		self.setupView(view);
	};

	while { (
		self[\multiContinuousWidgets].size
		< self[\paramsByType][\multiContinuous].size
	) } {
		view = ~gmWidgets.getMultiContinuousParam;
		self[\multiContinuousWidgets].add(view);
		self.setupView(view);
	};

	while { (
		self[\envWidgets].size
		< self[\paramsByType][\env].size
	) } {
		view = ~gmWidgets.getMetaEnv;
		self[\envWidgets].add(view);
		self.setupView(view);
	};

	while { (
		self[\tempoWidgets].size
		< self[\paramsByType][\tempo].size
	) } {
		view = ~gmWidgets.getTempoParam;
		self[\tempoWidgets].add(view);
		self.setupView(view);
	};

	while { (
		self[\outWidgets].size
		< self[\paramsByType][\out].size
	) } {
		view = ~gmWidgets.getDiscreteParam;
		self[\outWidgets].add(view);
		self.setupView(view);
	};
},

// Sub views construction
setupView: { |self, view|
	if(self[\style].notNil) {
		view.setStyles(
			self[\style],
			self[\textStyle],
			self[\widgetStyle]);
	};
},

visible: { |self, visible|
	self[\view].visible_(visible);
	self
},

//----------//
// OUT VIEW //
hideOut: { |self|
	self[\widgetsBySymbol][\out]
	[\view].visible_(false);
},

getOutView: { |self|
	self[\widgetsBySymbol][\out][\view]
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\style] = style;
	self[\textStyle] = textStyle;
	self[\widgetStyle] = widgetStyle;

	[
		self[\soundInWidgets],
		self[\continuousWidgets],
		self[\multiContinuousWidgets],
		self[\selectorWidgets],
		self[\envWidgets],
		self[\tempoWidgets],
		self[\outWidgets]
	].do({ |array|
		array.do({ |view|
			view.setStyles(
				style,
				textStyle,
				widgetStyle
			);
		});
	});
},

//--------//
//  MISC  //
getParam: { |self, symbol|
	self[\paramViews][symbol]
},

displayParamsMenu: { |self, visible|
	self[\paramViews].do({ |view|
			view.displayMenu(visible);
	});
	self
},

setMenusVisible: { |self, visible|
	self[\continuousWidgets].do({ |view|
		view.setMenuVisible(visible);
	});
	self
},

doRemove: { |self|
	// Clear collections
	self[\orderedViews].clear;
	self[\hiddenWidgets].clear;
	self[\hiddenViews].clear;
	// Clear widgets
	self[\continuousViews].do({ |view| view.doRemove; });
	self[\continuousViews].clear;
	self[\selectorViews].do({ |view| view.doRemove; });
	self[\selectorViews].clear;
	self[\envs].do({ |view| view.doRemove; });
	self[\envs].clear;
	self[\slider2Views].do({ |view| view.doRemove; });
	self[\slider2Views].clear;
	self[\tempoViews].do({ |view| view.doRemove; });
	self[\tempoViews].clear;
	self[\view].removeAll;
	self[\view].remove;
	self.clear;
},

deselectBeat: { |self|
	self[\selectorWidgets].do({ |widget|
		widget.deselectBeat;
	});
	self[\envWidgets].do({ |widget|
		widget.deselectBeat;
	});
	self[\multiContinuousWidgets].do({ |widget|
		widget.deselectBeat;
	});
},

selectBeat: { |self, index|
	self[\selectorWidgets].do({ |widget|
		widget.selectBeat(index);
	});
	self[\envWidgets].do({ |widget|
		widget.selectBeat(index);
	});
	self[\multiContinuousWidgets].do({ |widget|
		widget.selectBeat(index);
	});
},

hideParam: { |self, param|
	self[\widgetsBySymbol][param][\view].visible_(false);
},












//----------//
//  FIX ME  //

setPlayer: { |self, player|
	self[\player] = player;
	self[\continuousViews].do({ |view|
		view.setPlayer(player);
	});
	self[\multiContinuousViews].do({ |view|
		view.setPlayer(player);
	});
	self[\envs].do({ |view|
		view.setPlayer(player); });
	self[\selectorViews].do({ |view|
		view.setPlayer(player);
	});
	self[\slider2Views].do({ |view|
		view.setPlayer(player);
	});
	self[\tempoViews].do({ |view|
		view.setPlayer(player);
	});
},



// Allows communication between envViews and synthView
setTimeScale: { |self, symbol, timeScale|
	self[\synthView].setTimeScale(symbol, timeScale);
},

getTimeScale: { |self, symbol|
	self[\synthView].getTimeScale(symbol)
},

updateLayout: { |self|
	self.autoLayout(9);
},

autoLayout: { |self, prefStretch = 9|
	var currentIndex = 0;
	var views = List(0);
	var stretches = List(0);
	var nLayouts = 0;
	var targetStretch;
	var currentStretch = 0;
	var layouts = List(0);
	var currentLayout = 0;
	var layout =
	VLayout()
	.margins_(0)
	.spacing_(4);
	self[\orderedViews].do({ |view|
		if(view[\hidden].not) {
			views.add(view);
			view[\index] = currentIndex;
			currentIndex = currentIndex + 1;
			switch(view[\type])
			{ \continuous } {
				stretches.add(3);
			}
			{ \selector } {
				stretches.add(1);
			}
			{ \env } {
				stretches.add(3);
			}
			{ \slider2 } {
				stretches.add(3);
			}
			{ \tempo } {
				stretches.add(2);
			};
		};
	});
	currentIndex = 0;
	nLayouts = stretches.sum / prefStretch;
	if((nLayouts%1) < 0.5)
	{ nLayouts = nLayouts.trunc(1.0).asInteger; }
	{ nLayouts = nLayouts.roundUp.asInteger; };
	nLayouts = max(
		nLayouts,
		1
	);
	nLayouts.do({ |index|
		var subLayout = HLayout()
		.margins_(0)
		.spacing_(0);
		layouts.add(subLayout);
		layout.add(subLayout);
	});
	targetStretch = stretches.sum / nLayouts;
	targetStretch = targetStretch.roundUp;
	// Distribution inside layout could be optimized
	// to distribute stretches more evenly,
	// but this will do for now
	stretches.do({ |stretch, index|
		layouts[currentLayout].add(
			views[index][\view],
			stretch
		);
		views[index][\layout] = layouts[currentLayout];
		views[index][\layoutIndex] = currentIndex;

		currentStretch = currentStretch + stretch;

		if(currentStretch >= targetStretch) {
			currentLayout = currentLayout + 1;
			currentIndex = 0;
			currentStretch = currentStretch - targetStretch;
		} {
			currentIndex = currentIndex + 1;
		};
	});
	self[\paramView].layout.destroy;
	self[\paramView].layout_(layout);
	stretches.clear;
	views.clear;
},
)