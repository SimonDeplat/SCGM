(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\stretch] = Point(12, 3);

	self[\syncedViews] = true;
	self[\mode] = \determinist;

	self[\tracker] = ~gmWidgets.getTracker
	.beat(0)
	.connectSignal(
		\_valuesChanged,
		{ |triggers|
			self.updateTriggers(triggers);
		},
		self
	);

	self[\duoTracker] = ~gmWidgets.getDuoTracker
	.beat(0)
	.connectSignal(
		\_valuesChanged,
		{ |triggers|
			self.updateTriggers(triggers);
		},
		self
	);

	self[\stacklayout] = StackLayout()
	.add(self[\tracker][\view])
	.add(self[\duoTracker][\view]);

	self[\view] = UserView()
	.layout_(self[\stacklayout]);

	self
},

setSynth: { |self, synth|
	if(self[\synth].notNil) {
		self[\synth].disconnectNode(self);
		self[\rhythm].disconnectNode(self);
		self[\player].disconnectNode(self);
	};

	self[\synth] = synth;
	self[\triggers] = synth[\triggers];

	synth.connectSignal(
		\_triggersChanged,
		{ |triggers|
			self.setTriggers(triggers);
		},
		self
	);

	self[\updateTriggers] = { |self, triggers|
		self[\synth].setTriggers(triggers);
	};

	// RHYTHM
	self[\rhythm] = synth[\triggerRhythm];

	self[\rhythm][\player].connectSignal(
		\_postBeat,
		{ |beat|
			if(self[\syncedViews]) {
				self.displayBeat(beat);
			};
		},
		self
	);

	self[\rhythm][\player].connectSignal(
		\_stopped,
		{
			// FIX ME: OFFSET
			if(self[\syncedViews]) {
				self[\tracker].beat(0);
				self[\duoTracker].beat(0);
			};
		},
		self
	);

	// highlights
	self[\rhythm].connectSignal(
		\_highlights,
		{ |highlights|
			self[\tracker].highlights(
				self[\rhythm][\highlights]
			);
			self[\duoTracker].highlights(
				self[\rhythm][\highlights]
			);
		},
		self
	);

	self[\tracker].highlights(
		self[\rhythm][\highlights]
	);
	self[\duoTracker].highlights(
		self[\rhythm][\highlights]
	);

	self.displayTriggers;

	self
},

setTriggers: { |self, triggers|
	var isDeterminist = true;

	if(self[\triggers] != triggers) {
		self[\triggers] = triggers;

		// Update display
		self.displayTriggers;

		// Check if probabilist update is needed
		if(self[\mode] == \determinist) {
			triggers.do({ |trig|
				if(isDeterminist) {
					isDeterminist = (
						(trig == 0.0)
						or:
						{ trig == 1.0 }
					)
				};
			});
			if(isDeterminist.not) {
				self.setMode(\probabilist);
			};
		};
	};
	self
},

setMode: { |self, mode|
	var newTriggers;
	if(self[\mode] != mode) {
		self[\mode] = mode;
		if(mode == \determinist) {
			newTriggers =
			self[\triggers].collect({ |trig|
				if(trig != 1) {
					trig = 0;
				};
				trig
			});
			self.updateTriggers(newTriggers);
			self[\stacklayout].index_(0);
		} {
			self[\stacklayout].index_(1);
		};
	};
	self
},

displayBeat: { |self, beat|
	var canPlay = false;
	var beatIndex;
	(self[\rhythm][\depth] + 1).do({ |index|
		if(canPlay.not) {
			canPlay = (
				beat[\beatDetection][index]
				== 1
			);
		};
	});
	if(canPlay) {
		beatIndex =
		(beat[\absGrid][self[\rhythm][\depth]] - 1)
		+ self[\rhythm][\offset]
		% self[\synth][\triggers].size;

		self[\tracker].beat(beatIndex);
		self[\duoTracker].beat(beatIndex);
	};
},

displayIndex: { |self, index|
	self[\tracker].beat(index % self[\triggers].size);
	self[\duoTracker].beat(index % self[\triggers].size);
},

displayTriggers: { |self|
	self[\tracker].setValues(
		self[\triggers].collect({ |trigger|
			if(trigger != 1) {
				trigger = 0;
			};
			trigger
		});
	);
	self[\duoTracker].setValues(self[\triggers]);
},
)