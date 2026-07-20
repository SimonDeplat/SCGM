(
init: { |self|
	self[\type] = \env;
	// Implement signal system
	~gmDefs.implSignals(self);
	self
},

setParam: { |self, param|
	// Param is in the GMDef format
	self[\symbol] = param[\symbol];
	self[\default] = param[\default];
	self[\value] = param[\default].copy;
	self[\env] = self[\value];
	self[\track] = [self[\value]];
	self[\mode] = \value;
},

setSynth: { |self, synth|
	self[\synth] = synth;
},

setRhythm: { |self, rhythm|
	if(self[\rhythm] != rhythm) {
		// Disconnect previous signal
		if(self[\rhythm].notNil) {
			self[\rhythm].disconnectNode(self);
		};
		// Register
		self[\rhythm] = rhythm;
		// Update track
		self.setTrack(
			Array.fill(
				rhythm[\size],
				self[\value]
			);
		);
		// Connect size changed signal
		rhythm.connectSignal(
			\_sizeChanged,
			{ |size|
				self.setTrack(
					Array.fill(
						size,
						self[\value]
					);
				);
			},
			self
		);
		// Notify rhythm change
		self.emitSignal(
			\_rhythmChanged,
			rhythm
		);
	};
	self
},

setValue: { |self, value|
	if(value != self[\value]) {
		self[\value] = value;
		self[\env] = self[\value];
		self.emitSignal(
			\_valueChanged,
			self[\value]
		);
		self.emitSignal(
			\_envChanged,
			self[\value]
		);
	};
	self
},

setEnv: { |self, env|
	self.setValue(env);
	self
},

setTrack: { |self, track|
	if(track != self[\track]) {
		self[\track] = track.copy;
		self.emitSignal(
			\_trackChanged,
			self[\track]
		);
	};
	self
},

setMode: { |self, mode|
	if(mode != self[\mode]) {
		self[\mode] = mode;
		self.emitSignal(
			\_modeChanged,
			self[\mode]
		);
	};
	self
},

getAtIndex: { |self, index|
	var value;
	if(self[\mode] == \value) {
		value = self[\value];
	} {
		value =
		self[\track][index % self[\track].size]
	};
	value
},

getAtBeat: { |self, beat|
	var value;
	if(self[\mode] == \value) {
		value = self[\value];
	} {
		value = self[\track][
			(beat[\absGrid][self[\rhythm][\depth]] - 1)
			+ self[\rhythm][\offset]
			% self[\track].size;
		]
	};
	value
},

doRemove: { |self|
	self.emitSignal(\_removed);
	self.clear;
},
)