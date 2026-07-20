(
~gmWidgets = (
	init: { |self|
		self[\folder] = thisProcess.nowExecutingPath.dirname;
		self.loadWidgets;
		self[\uidCounter] = 0;
		self.setStyle(
			GMStyle()
			.fontColor_(Color.black)
		);
		self[\icons] = this.executeFile(
			self[\folder] ++ "/collections/iconsNames.scd"
		);
		self[\loadDirectory] = Platform.userHomeDir;
		self[\saveDirectory] = Platform.userHomeDir;
		self
	},

	version: "1.0.0-beta",

	titleSize: 26,

	//--------------//
	// Constructors //
	getInstance: { |self, parent|
		var instance = ();
		instance.parent_(self[parent]);
		instance.init;
		instance
	},

	loadWidgets: { |self|
		self[\paramViewParent] = this.executeFile(
			self[\folder] ++ "/tools/paramViewParent.scd"
		);

		[
			// Abstract
			[\getSynthView, \synthView,
				"/Abstract/synthView.scd"],
			[\getChainView, \chainView,
				"/Abstract/chainView.scd"],
			[\getChaosPad, \chaosPad,
				"/Abstract/chaosPad.scd"],
			[\getMiniPlayerView, \miniPlayerView,
				"/Abstract/miniPlayerView.scd"],
			[\getNoteSelector, \noteSelector,
				"/Abstract/noteSelector.scd"],
			[\getRhythmView, \rhythmView,
				"/Abstract/rhythmView.scd"],
			[\getMenu, \menu,
				"/Abstract/menu.scd"],
			[\getLayout, \layout,
				"/Abstract/layout.scd"],
			[\getTriggerView, \triggerView,
				"/Abstract/triggerView.scd"],
			[\getPianoRollView, \pianoRollView,
				"/Abstract/pianoRollView.scd"],
			[\getFileLoader, \fileLoader,
				"/Abstract/fileLoader.scd"],

			// IO
			[\getOutView, \outView,
				"/Abstract/outView.scd"],
			[\getInView, \inView,
				"/Abstract/inView.scd"],
			[\getSoundInView, \soundInView,
				"/Abstract/soundInView.scd"],

			// Tools
			[\getParamManager, \paramManager,
				"/tools/paramManager.scd"],
			[\getBeatSelector, \beatSelector,
				"/tools/beatSelector.scd"],

			// Params
			[\getContinuousParam, \continuousParam,
				"/tools/continuousParam.scd" ],
			[\getMultiContinuousParam, \multiContinuousParam,
				"/tools/multiContinuousParam.scd" ],
			[\getDiscreteParam, \discreteParam,
				"/tools/discreteParam.scd"],
			[\getTempoParam, \tempoParam,
				"/tools/tempoParam.scd"],
			[\getMetaEnv, \metaEnv,
				"/tools/metaEnv.scd"],

			// Widgets
			[\getTextView, \textView,
				"/Widgets/textView.scd"],
			[\getButton, \button,
				"/Widgets/button.scd"],
			[\getSwitch, \switch,
				"/Widgets/switch.scd"],
			[\getSelector, \selector,
				"/Widgets/selector.scd"],
			[\getSlider, \slider,
				"/Widgets/slider.scd"],
			[\getSymbolSlider, \symbolSlider,
				"/Widgets/symbolSlider.scd"],
			[\getMultiSlider, \multiSlider,
				"/Widgets/multiSlider.scd"],
			[\getSlider2D, \slider2D,
				"/Widgets/slider2D.scd"],
			[\getTapTempo, \tapTempo,
				"/Widgets/tapTempo.scd"],
			[\getEnv, \env,
				"/Widgets/env.scd"],
			[\getKeyboard, \keyboard,
				"/Widgets/keyboard.scd"],
			[\getPlayStopButton, \playStopButton,
				"/Widgets/playStopButton.scd"],
			[\getPianoRoll, \pianoRoll,
				"/Widgets/pianoRoll.scd"],
			[\getTracker, \tracker,
				"/Widgets/tracker.scd"],
			[\getDuoTracker, \duoTracker,
				"/Widgets/duoTracker.scd"],
			[\getGridView, \gridView,
				"/Widgets/gridView.scd"],

		].do({ |array|
			self[array[0]] = {
				self[array[1]] = this.executeFile(
					self[\folder]
					++ array[2]
				);
				self[array[0]] =
				{ self.getInstance(array[1]) };
				self.getInstance(array[1])
			};
		});
	},

	getRandomStyles: { |self|
		var style, color, color2;

		color = Color.rand;
		color2 = Color.rand;

		style = GMStyle()
		.mainColor_(color)
		.backColor_(
			Color(
				color.red * 0.7,
				color.green * 0.7,
				color.blue * 0.7
			)
		)
		.borderColor_(color)
/*		.backgroundColor_(
			Color(
				color2.red * 0.7,
				color2.green * 0.7,
				color2.blue * 0.7
			)
		)*/

		.borderSize_(4)
		.secondBorderSize_(2)
		.thirdBorderSize_(0);
		[
			style,
			style
			.deepCopy
			.borderSize_(2)
			.secondBorderSize_(0)
			.thirdBorderSize_(0),
			style
			.deepCopy
		]
	},

	//------------------//
	// GLOBAL VARIABLES //
	textboxMaxSize: 64,
	widgetSpacing: 2,

	//------------------//
	// GLOBAL FUNCTIONS //
	getTitle: { |self, string = ""|
		GMTextView()
		.displayFrame_(true)
		.string_(string)
		.style_(self[\widgetStyle])
		.minHeight_(self[\titleSize] * 0.8)
		.maxHeight_(self[\titleSize] * 1.2)
		.fontRatio_(0.8)
	},

	doCopy: { |self, symbol, data|
		self[\copyPaste][symbol] = data;
	},

	doPaste: { |self, symbol|
		var data = nil;
		if(self[\copyPaste][symbol].notNil) {
			data = self[\copyPaste][symbol].deepCopy;
		};
		data
	},

	getUID: { |self|
		var uid = Date.getDate.format("%d%H%M%S");
		uid = uid ++ self[\uidCounter].asString;
		self[\uidCounter] = self[\uidCounter] + 1;
		uid = $$ ++ uid;
		uid = uid.asSymbol;
		uid
	},

	// Style
	setStyle: { |self, style|
		self[\style] = style;

		self[\textStyle] = style.deepCopy
		.borderSize_(2)
		.secondBorderSize_(0)
		.thirdBorderSize_(0);

		self[\widgetStyle] = style.deepCopy
		.borderSize_(1)
		.secondBorderSize_(1)
		.thirdBorderSize_(1);
	},

	setStyles: { |self, style, textStyle, widgetStyle|
		self[\style] = style;
		self[\textStyle] = textStyle;
		self[\widgetStyle] = widgetStyle;
	},

	//--------//
	// ASSETS //
	getIcon: { |self, symbol|
		self[\folder] ++ "/icons/" ++ self[\icons][symbol]
	},
).init;
)