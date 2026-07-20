(
init: { |self|
	self[\type] = \buffer;
	self[\signals] = ();
	self
},

//---------//
// METHODS //
setValue: { |self, value|
	if(value != self[\value]) {
		self[\value] = value;
		self.emitSignal(
			\_valueChanged,
			self[\value]
		);
	};
},

//---------//
// SIGNALS //
emitSignal: { |self, symbol, args = nil|
	if(self[\signals].includesKey(symbol)) {
		if(args.isNil) {
			self[\signals][symbol].value;
		} {
			self[\signals][symbol].value(args);
		};
	};
},

connectSignal: { |self, symbol, function|
	if(self[\signals][symbol].isNil) {
		self[\signals][symbol] = FunctionList();
	};
	self[\signals][symbol].addFunc(function);
	self
},

disconnectSignal: { |self, symbol, function|
	if(self[\signals].includesKey(symbol)) {
		self[\signals][symbol].removeFunc(function);
	};
},

clearSignal: { |self, symbol|
	self[\signals].removeAt(symbol);
},

clearAllSignals: { |self|
	self[\selector].clearSignal(
		\_stateChanged
	);
},

//------//
// MISC //
doRemove: { |self|
	self.emitSignal(\removed);
	self.clear;
},
)