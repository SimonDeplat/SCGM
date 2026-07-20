(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(3, 1);

	self[\displayView] = GMButton()
	.svg_(~gmWidgets.getIcon(\loadFile));
	self[\interactView] = UserView()
	.mouseDownAction_({
		var dialog = FileDialog(
			{ |file|
				self.loadFile(file[0]);
				~gmWidgets[\loadDirectory] =
				PathName(file[0]).pathOnly;
			},
			{ },
			1,
			0,
			true,
			~gmWidgets[\loadDirectory]
		);
	})
	.canReceiveDragHandler_({ true })
	.receiveDragHandler_({
		self.loadFile(View.currentDrag);
	});
	self[\view] = UserView()
	.layout_(
		StackLayout()
		.mode_(\stackAll)
		.add(self[\interactView])
		.add(self[\displayView])
	);
	self
},

loadFile: { |self, path|
	self.emitSignal(
		\_fileLoaded,
		path
	);
	self[\displayView].free;
	self[\displayView].string_(
		PathName(path).fileName
	);
},

orientation: { |self, orientation|
	self[\displayView].orientation_(
		orientation
	);
	self
},
)