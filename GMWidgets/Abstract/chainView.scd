(
init: { |self|
	self[\signals] = ();
	self[\spacing] = 6;
	self.initView;
	self
},

initView: { |self|
	self[\title] = ~gmWidgets.getTitle
	.orientation_(\top)
	.maxHeight_(1080)
	.maxWidth_(32);
	self[\container] = UserView()
	.layout_(
		VLayout()
		.margins_(0)
		.spacing_(self[\spacing])
	);
	self[\view] = UserView()
	.background_(Color.black)
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(self[\spacing])
		.add(self[\title], 1)
		.add(self[\container], 9)
	);
},

//---------//
// METHODS //
name: { |self, name|
	self[\title].string_(name);
	self
},

setChain: { |self, chain|

	self[\chain] = chain;
	self[\synthViews] = List(0);
	self[\synthViewsByName] = ();

	chain[\synths].do({ |synth, index|
		var view;

		view = ~gmWidgets.getSynthView;
		// Ugly, but can't access Layout children:
		view[\layoutIndex] = index;
		self[\container].layout
		.add(view[\view], view[\stretch].x);

		// /!\ Set synth after adding views
		// to the layout
		view.setSynth(synth);
		self[\synthViewsByName][synth[\name].asSymbol] = view;
		self[\synthViews].add(view);
		if((index + 1) < chain[\synths].size) {
			view.hideOut;
		} {
			/*// FIX ME: WILL CAUSE PROBLEM LATER
			if(synth[\type] != \dispatch) {
				self[\synthViewsLayout].add(
					view.getOutView, 1
				);
			}*/
		};
	});
	self
},

setMenusVisible: { |self, visible|
	self[\synthViews].do({ |view|
		view.setMenusVisible(visible);
	});
	self
},

hideSynth: { |self, name|
	self[\synthViewsByName][name.asSymbol]
	[\view].visible_(false);
	self
},

getSynthView: { |self, name|
	self[\synthViewsByName][name.asSymbol]
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].background_(
		Color(
			style.backColor.red * 0.25,
			style.backColor.green * 0.25,
			style.backColor.blue * 0.25
		)
	);
	self[\title].style_(textStyle);
	if(self[\gridView].notNil) {
		self[\gridView].style_(style);
	};
	self[\synthViews].do({ |view|
		view.setStyles(
			style,
			textStyle,
			widgetStyle
		);
	});
	self
},

setAsGridView: { |self, gridSubdivisions = nil|
	var gridView, gridSize, currentPosition;

	if(gridSubdivisions.isNil) {
		gridSubdivisions = Point(1, 1);
	};

	gridSize = Point(0, 0);

	self[\synthViews].do({ |view|
		gridSize.x = gridSize.x + view[\stretch].x;
		if(view[\stretch].y > gridSize.y) {
			gridSize.y = view[\stretch].y;
		};
	});

	gridView = ~gmWidgets.getGridView
	.gridSize(gridSize * gridSubdivisions);

	currentPosition = Point(0, 0);
	self[\synthViews].do({ |view|
		gridView.addView(
			view[\view],
			currentPosition.deepCopy,
			view[\stretch]
		);
		currentPosition.x = currentPosition.x
		+ (view[\stretch].x * gridSubdivisions.x);
	});

	// self[\view].layout.destroy;
	self[\container].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(gridView[\view])
	);
	self
},

setAsHorizontalGridView: { |self, gridSubdivisions = nil|
	var gridView, gridSize, currentPosition;

	if(gridSubdivisions.isNil) {
		gridSubdivisions = Point(1, 1);
	};

	gridSize = Point(0, 0);

	self[\synthViews].do({ |view|
		gridSize.x = gridSize.x + view[\stretch].x;
		if(view[\stretch].y > gridSize.y) {
			gridSize.y = view[\stretch].y;
		};
	});
	gridView = ~gmWidgets.getGridView
	.gridSize(gridSize * gridSubdivisions);

	currentPosition = Point(0, 0);
	self[\synthViews].do({ |view|
		gridView.addView(
			view[\view],
			currentPosition.deepCopy,
			Point(view[\stretch].x, gridSize.y) * gridSubdivisions
		);
		currentPosition.x = currentPosition.x
		+ (view[\stretch].x * gridSubdivisions.x);
	});

	// self[\view].layout.destroy;
	self[\container].layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(gridView[\view])
	);

	self
},

setHorizontal: { |self|
	var layout = HLayout()
	.margins_(0)
	.spacing_(self[\spacing]);
	self[\synthViews].do({ |view|
		layout.add(
			view[\view],
			view[\stretch].x
		);
	});
	self[\container].layout_(layout);
	self
},

setVertical: { |self|
	var layout = VLayout()
	.margins_(0)
	.spacing_(self[\spacing]);
	self[\synthViews].do({ |view|
		layout.add(
			view[\view],
			view[\stretch].y
		);
	});
	self[\container].layout_(layout);
	self
},

visible: { |self, visible|
	self[\view].visible_(visible);
	self
},
)