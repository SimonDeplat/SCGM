(
init: { |self|
	self[\orientation] = \vertical;
	self[\views] = List(0);
	self[\layout] = VLayout()
	.margins_(0)
	.spacing_(2);
	self[\view] = UserView()
	.maxWidth_(64)
	.maxHeight_(9999)
	.layout_(
		self[\layout]
	);
	self
},

setOrientation: { |self, orientation|
	if(self[\orientation] != orientation) {
		self[\orientation] = orientation;
		if(orientation == \horizontal) {
			self[\layout] = HLayout()
			.margins_(0)
			.spacing_(2);
			self[\view] = UserView()
			.maxWidth_(9999)
			.maxHeight_(64);
		} {
			self[\layout] = VLayout()
			.margins_(0)
			.spacing_(2);
			self[\view] = UserView()
			.maxWidth_(64)
			.maxHeight_(9999);
		};
		self[\views].do({ |view|
			self[\layout].add(view[\view]);
		});
		self[\view].layout_(self[\layout]);
	};
	self
},

addText: { |self, string = ""|
	var textView = ~gmWidgets.getTextView
	.string(string);
	self[\views].add(textView);
	self[\layout].add(textView[\view]);
	textView
},

addButton: { |self|
	var button = ~gmWidgets.getButton;
	self[\views].add(button);
	self[\layout].add(button[\view]);
	button
},

addSwitch: { |self|
	var switch = ~gmWidgets.getSwitch;
	self[\views].add(switch);
	self[\layout].add(switch[\view]);
	switch
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\views].do({ |view|
		view.setStyles(style, textStyle, widgetStyle);
		/*if(view[\type] == \switch) {
			view.setColorAll(widgetStyle.backColor);
		};*/
	});
	self
},

visible: { |self, visible|
	self[\view].visible_(visible);
	self
},
)