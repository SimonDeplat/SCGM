(
init: { |self|
	self[\type] = \discrete;
	// Implement signal system
	~gmDefs.implSignals(self);
	self
},

setParam: { |self, param|
	// Param is in the GMDef format
	self[\type] = param[\type];
	self[\symbol] = param[\symbol];
	self[\default] = param[\default];
	self[\value] = param[\default].copy;
	self[\values] = param[\values].copy;
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
		self.emitSignal(
			\_valueChanged,
			self[\value]
		);
	};
},

setValueIndex: { |self, index|
	if(
		self[\values].notNil
		and: { self[\values][index] != self[\value] }
	) {
		self[\value] = self[\values][index];
		self.emitSignal(
			\_valueChanged,
			self[\value]
		);
	};
},

getValueIndex: { |self, index|
	var value = nil;
	if(self[\values].notNil) {
		value = self[\values][index];
	};
	value
},

setValues: { |self, values|
	if(values != self[\values]) {
		self[\values] = values.copy;
		self.emitSignal(
			\_valuesChanged,
			self[\values]
		);
		// Clip current value
		if(self[\values].includesEqual(
			self[\value]).not
		) {
			self[\value] = self[\values][0];
			self.emitSignal(
				\_valueChanged,
				self[\value]
			);
		};
	};
},

setTrack: { |self, track|
	if(track != self[\track]) {
		self[\track] = track.copy;
		// Clip values
		self[\track].do({ |value, index|
			if(self[\values].includesEqual(value).not) {
				self[\track][index] = self[\values][0];
			};
		});
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