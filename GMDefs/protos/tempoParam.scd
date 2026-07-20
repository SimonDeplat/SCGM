(
init: { |self|
	~gmDefs.implSignals(self);
	self
},

setParam: { |self, param|
	// Param is in the GMDef format
	self[\type] = param[\type];
	self[\symbol] = param[\symbol];
	self[\default] = 1;
	self[\rate] = 1;
	self[\mul] = 1;
	self[\track] = [self[\mul]];
	self[\value] = self[\rate] * self[\mul];
	self[\mode] = \value;
},

//---------//
// METHODS //
setValue: { |self, value|
	self.setMul(value);
},

setRate: { |self, rate|
	if(rate != self[\rate]) {
		self[\rate] = rate;
		self.updateValue;
	};
},

setMul: { |self, mul|
	if(mul != self[\mul]) {
		self[\mul] = mul;
		self.emitSignal(
			\_mulChanged,
			self[\mul]
		);
		self.updateValue;
	};
},

updateValue: { |self|
	self[\value] = self[\rate] * self[\mul].reciprocal;
	if(self[\type] == \tempoRate) {
		self[\value] = self[\value].reciprocal;
	};
	self.emitSignal(
		\_valueChanged,
		self[\value]
	);
},

// FIX ME:
getAtIndex: { |self, index|
	self[\value]
},

// FIX ME:
getAtBeat: { |self, index|
	self[\value]
},

//------//
// MISC //
doRemove: { |self|
	self.emitSignal(\_removed);
	self.clear;
},
)