(
init: { |self|
	self[\type] = \continuous;
	// Implement signal system
	~gmDefs.implSignals(self);
	self
},

setParam: { |self, param|
	// Param is in the GMDef format
	self[\paramDict] = param;
	self[\symbol] = param[\symbol];
	self[\default] = param[\default];
	self[\min] = param[\min];
	self[\max] = param[\max];
	self[\scale] = param[\scale];
	self[\randClip] = [param[\min], param[\max]];
	self[\value] = param[\default];
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
		self[\value] = self.clip(value);
		self.emitSignal(
			\_valueChanged,
			self[\value]
		);
	};
},

setTrack: { |self, track|
	if(track != self[\track]) {
		self[\track] = track.copy;
		// Clip values
		self[\track].do({ |value, index|
			self[\track][index] = self.clip(value);
		});
		self.emitSignal(
			\_trackChanged,
			self[\track]
		);
	};
	self
},

randomize: { |self, min = nil, max = nil|

	if(min.notNil) {
		self[\randClip][0] = min;
	};

	if(max.notNil) {
		self[\randClip][1] = max;
	};

	switch(self[\scale])
	{ \lin } {
		self.setValue(
			(1.0.rand).linlin(
				0, 1,
				self[\randClip][0],
				self[\randClip][1]
			)
		);
		self.setTrack(
			Array.fill(
				self[\track].size, {
					(1.0.rand).linlin(
						0, 1,
						self[\randClip][0],
						self[\randClip][1]
					)
				}
			)
		);
	}

	{ \exp } {
		self.setValue(
			(1.0.rand).linexp(
				0, 1,
				self[\randClip][0],
				self[\randClip][1]
			)
		);
		self.setTrack(
			Array.fill(
				self[\track].size, {
					(1.0.rand).linexp(
						0, 1,
						self[\randClip][0],
						self[\randClip][1]
					)
				}
			)
		);
	}

	{ \log } {
		self.setValue(
			(1.0.rand).linexp(
				0, 1,
				self[\randClip][1],
				self[\randClip][0]
			)
		);
		self.setTrack(
			Array.fill(
				self[\track].size, {
					(1.0.rand).linexp(
						0, 1,
						self[\randClip][1],
						self[\randClip][0]
					)
				}
			)
		);
	}

	{
		self.setValue(
			(1.0.rand).linexp(
				0, 1,
				self[\randClip][0],
				self[\randClip][1],
				self[\scale]
			)
		);
		self.setTrack(
			Array.fill(
				self[\track].size, {
					(1.0.rand).linexp(
						0, 1,
						self[\randClip][0],
						self[\randClip][1],
						self[\scale]
					)
				}
			)
		);
	};

	self
},

setMin: { |self, min|
	if(min != self[\min]) {
		self[\min] = min;
		if(self[\randClip][0] < min) {
			self[\randClip][0] = min;
		};
		self.emitSignal(
			\_minChanged,
			self[\min]
		);
		// Clip current value
		if(self[\value] != self.clip(self[\value])) {
			self[\value] = self.clip(self[\value]);
			self.emitSignal(
				\_valueChanged,
				self[\value]
			);
		};
		// FIX ME: CLIP TRACK
	};
},

setMax: { |self, max|
	if(max != self[\max]) {
		self[\max] = max;
		if(self[\randClip][1] > max) {
			self[\randClip][1] = max;
		};
		self.emitSignal(
			\_maxChanged,
			self[\max]
		);
		// Clip current value
		if(self[\value] != self.clip(self[\value])) {
			self[\value] = self.clip(self[\value]);
			self.emitSignal(
				\_valueChanged,
				self[\value]
			);
		};
	};
	// FIX ME: CLIP TRACK
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

doReset: { |self|
	self.setValue(self[\default]);
	self.setTrack(
		Array.fill(
			self[\track].size,
			{ self[\default] }
		);
	);
},

//-----------------//
// PRIVATE METHODS //
clip: { |self, value|
	value = max(
		value,
		self[\min]
	);

	value = min(
		value,
		self[\max]
	);
	value
},

//------//
// MISC //
doRemove: { |self|
	self.emitSignal(\_removed);
	self.clear;
},
)