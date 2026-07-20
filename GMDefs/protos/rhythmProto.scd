(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\id] = ~gmDefs.getUID;
	self[\type] = \rhythm;
	self[\bound] = true;
	self[\size] = 1;
	self[\depth] = 0;
	self[\mul] = 1;
	self[\offset] = 0;
	self[\highlights] = [];

	self
},

bindRhythm: { |self, depth = 0, mul = 1, offset = 0|
	self[\bound] = true;
	self.setDepth(depth, false);
	self.setMul(mul, false);
	self.setOffset(offset);
	self.updateSize;
	self
},

autoBindRhythm: { |self, depth = 0|
	var mul = 1;
	if(self[\player].notNil) {
		self[\bound] = true;
		self.setDepth(depth, false);
		if(depth > 1) {
			mul = self[\player][\divisions][depth - 1];
			self.setMul(mul, false);
		};
		self.updateSize;
	};
	self
},

unbindRhythm: { |self, depth = 0, size = 1, offset = 0|
	self[\bound] = false;
	self.setDepth(depth, false);
	self.setOffset(offset);
	if(self[\size] != size) {
		self[\size] = size;
		self.emitSignal(
			\_sizeChanged,
			self[\size]
		);
	};
	self
},

// FIX ME: PLAYER CHANGED
setPlayer: { |self, player|
	self[\player] = player;
	self.updateSize;
	player.connectSignal(
		\_divChanged,
		{ self.updateSize; },
		self
	);
	self
},

setDepth: { |self, depth, update = true|
	if(self[\depth] != depth) {
		self[\depth] = depth;
		self.emitSignal(
			\_depthChanged,
			self[\depth]
		);
		if(update) {
			self.updateSize;
		};
	};
	self
},

setMul: { |self, mul, update = true|
	if(self[\mul] != mul) {
		self[\mul] = mul;
		self.emitSignal(
			\_mulChanged,
			self[\mul]
		);
		if(update) {
			self.updateSize;
		};
	};
	self
},

setOffset: { |self, offset|
	if(self[\offset] != offset) {
		self[\offset] = offset;
		self.emitSignal(
			\_offsetChanged,
			self[\offset]
		);
	};
	self
},

updateSize: { |self|
	var currentSize = self[\size];
	if(
		self[\player].notNil
		and:
		{ self[\bound] }
	) {
		self[\size] =
		self[\player][\divisions][self[\depth]]
		* self[\mul];
		if(self[\size] != currentSize) {
			self.emitSignal(
				\_sizeChanged,
				self[\size]
			);
		};
		self.updateHighlights;
	};
},

updateHighlights: { |self|
	var newHighlights, times, filler;

	// FIX ME: OFFSET

	if(self[\player].notNil) {

		newHighlights = [];

		switch(self[\player][\divisions][self[\depth]])
		{ 1 } {
			times = [0.9];
		}
		{ 2 } {
			times = [0.9, 0.5];
		}
		{ 3 } {
			times = [0.9, 0.5, 0.5];
		}
		{ 4 } {
			times = [0.9, 0.5, 0.75, 0.5];
		}
		{ 5 } {
			times = [0.9, 0.5, 0.75, 0.5, 0.5];
		}
		{ 6 } {
			times = [0.9, 0.5, 0.5, 0.75, 0.5, 0.5];
		}
		{ 7 } {
			times = [0.9, 0.5, 0.5, 0.5, 0.75, 0.5, 0.5];
		}
		{ 8 } {
			times = [0.9, 0.5, 0.65, 0.5, 0.8, 0.5, 0.65, 0.5];
		}
		{ 9 } {
			times = [0.9, 0.5, 0.5, 0.75, 0.5, 0.5, 0.75, 0.5, 0.5];
		}
		{
			times = Array.fill(
				self[\player][\divisions][self[\depth]],
				{ 0.5 }
			);
			times[0] = 1;
		};

		switch(self[\player][\divisions][self[\depth]])
		{ 1 } {
			filler = [];
		}
		{ 2 } {
			filler = [0];
		}
		{ 3 } {
			filler = [0, 0];
		}
		{ 4 } {
			filler = [0, 0.333, 0];
		}
		{ 5 } {
			filler = [0, 0, 0.333, 0];
		}
		{ 6 } {
			filler = [0, 0, 0.333, 0, 0];
		}
		{ 7 } {
			filler = [0, 0, 0, 0.333, 0, 0];
		}
		{ 8 } {
			filler = [0, 0.222, 0, 0.333, 0, 0.222, 0];
		}
		{ 9 } {
			filler = [0, 0, 0.333, 0, 0, 0.333, 0, 0];
		}
		{
			times = Array.fill(
				self[\player][\divisions][self[\depth] + 1],
				{ 0 }
			);
		};

		self[\mul].do({
			self[\player][\divisions][self[\depth]].do({ |index|
				newHighlights = newHighlights ++ [times[index]];
				newHighlights = newHighlights ++ filler;
			});
		});

		if(self[\highlights] != newHighlights) {
			self[\highlights] = newHighlights;
			self.emitSignal(
				\_highlights,
				self[\highlights]
			);
		};
	};
},

doCopy: { |self, rhythm|
	if(self != rhythm) {
		self.setDepth(rhythm[\depth]);
		self.setMul(rhythm[\mul]);
		self.setOffset(rhythm[\offset]);
	};
},

getSaveDatas: { |self|
	(
		divisions: self[\player][\divisions],
		depth: self[\depth],
		mul: self[\mul],
		offset: self[\offset]
	)
},
)