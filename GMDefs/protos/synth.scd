// This is the "Class"
// every synth inherits from

(
//------//
// CORE //
initParent: { |self, datas|

	var paramIndex = 0;
	var params = ();

	self[\datas] = datas;
	// Implement signal system
	~gmDefs.implSignals(self);

	// GENERAL VARIABLES
	self[\id] = ~gmDefs.getUID;
	self[\symbol] = self[\datas][\symbol];
	self[\type] = self[\datas][\type];
	self[\emission] = self[\datas][\emission];
	self[\name] = datas[\name];
	self[\tunable] = datas[\tunable];
	self[\player] = nil;
	self[\track] = List(0);
	self[\defaultArgs] = ();
	self[\args] = ();
	self[\numKernels] = 0;
	self[\outPlugs] = ();
	self[\extOutPlugs] = ();
	self[\ready] = false;
	self[\group] = datas[\group];
	self[\groupIndex] = 0;

	switch(self[\group])
	{ \control } {
		self[\target] =
		~gmDefs[\controlGroups][self[\groupIndex]];
	}
	{ \synth } {
		self[\target] =
		~gmDefs[\sourceGroup];
	}
	{ \filter } {
		self[\target] =
		~gmDefs[\filterGroups][self[\groupIndex]];
	};

	// SPECIAL VARIABLES (?)
	self[\hasAmp] = false;
	self[\hasTempo] = false;
	self[\currentBeat] = -1;
	self[\nBeats] = 1;

	// ---- PARAM LOADING ---- //
	self[\paramsByType] = (
		continuous: List(0),
		multiContinuous: List(0),
		discrete: List(0),
		slider2: List(0),
		env: List(0),
		tempo: List(0),
		buffer: List(0),

		out: List(0),
		in: List(0),
		soundIn: List(0),
	);

	self[\params] = ();
	self[\paramsByIndex] = List.newClear(datas[\params].size);

	datas[\params].copy.keysValuesDo({ |symbol, paramDict, index|

		var param;

		switch(paramDict[\type])

		{ \continuous } {
			param = ~gmDefs.getContinuousParam;
			param.setSynth(self);
			self[\params][paramDict[\symbol]] = param;
			param.setParam(paramDict);
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\continuous].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \multiContinuous } {
			param = ~gmDefs.getMultiContinuousParam;
			self[\params][paramDict[\symbol]] = param;
			param.setParam(paramDict);
			param.connectSignal(
				\_valueChanged,
				{ |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				},
				self
			);
			self[\paramsByType]
			[\multiContinuous].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \discrete } {
			param = ~gmDefs.getDiscreteParam;
			self[\params][paramDict[\symbol]] = param;
			param.setParam(paramDict);
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\discrete].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \env } {
			param = ~gmDefs.getEnvParam;
			self[\params][paramDict[\symbol]] = param;
			param.setParam(paramDict);
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\env].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \tempoRate } {
			param = ~gmDefs.getTempoParam;
			self[\params][paramDict[\symbol]] = param;
			param.setParam(paramDict);
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\tempo].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \tempoDur } {
			param = ~gmDefs.getTempoParam;
			self[\params][paramDict[\symbol]] = param;
			param.setParam(paramDict);
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\tempo].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \out } {
			param = ~gmDefs.getDiscreteParam;
			self[\params][paramDict[\symbol]] = param;
			paramDict[\values] = Array.fill(
				~gmDefs[\server].options.numOutputBusChannels
				/ paramDict[\numChannels], { |i|
					i * paramDict[\numChannels]
				};
			);
			param.setParam(paramDict);
			if(param[\symbol] == \out) {
				param.setValue(0);
			} {
				param.setValue(2);
			};
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\out].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \in } {
			param = ~gmDefs.getDiscreteParam;
			param.setParam(paramDict);
			param[\value] = Bus.audio(
				~gmDefs[\server],
				paramDict[\numChannels]
			);

			self[\params][paramDict[\symbol]] = param;

			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\in].add(param);
			self[\paramsByIndex][index] = param;

			self[\defaultArgs][param[\symbol]]
			= param[\value];

			if(self[\busses].isNil) {
				self[\busses] = ();
			};

			self[\busses][param[\symbol]]
			= param[\value];

			if(self[\inPlugs].isNil) {
				self[\inPlugs] = ();
			};
		}

		{ \rate } {
			self[\defaultArgs][param[\symbol]]
			= 1;
		}

		{ \soundIn } {
			param = ~gmDefs.getDiscreteParam;
			self[\params][paramDict[\symbol]] = param;
			paramDict[\values] = Array.fill(
				~gmDefs[\server].options.numInputBusChannels
				/ paramDict[\numChannels], { |i|
					i * paramDict[\numChannels]
				};
			);
			param.setParam(paramDict);
			param.setValue(0);
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\soundIn].add(param);
			self[\paramsByIndex][index] = param;
			self[\defaultArgs][param[\symbol]]
			= param[\value];
		}

		{ \buffer } {
			param = ~gmDefs.getBufferParam;
			self[\params][paramDict[\symbol]] = param;
			param.connectSignal(
				\_valueChanged, { |value|
					self.updateParam(
						param,
						paramDict[\symbol],
						value
					);
				};
			);
			self[\paramsByType]
			[\buffer].add(param);
			self[\paramsByIndex][index] = param;
		}

		{ \kernel } {
			self[\numKernels] = self[\numKernels] + 1;
			Buffer.loadCollection(
				~gmDefs[\server],
				Array.fill(
					paramDict[\size] * paramDict[\channels],
					{ 0 }
				),
				paramDict[\channels],
				{ |b|
					self[\defaultArgs][paramDict[\symbol]] = b;
					self[\args][paramDict[\symbol]] = b;
					self[\numKernels] = self[\numKernels] - 1;
					if(
						self[\numKernels] == 0
						and:
						{ self[\emission] == \continuous }
					) {
						self.doPlay;
					};
				}
			);
		};
	});

	self[\paramsByIndex] =
	self[\paramsByIndex].select({ |item|
		item.notNil
	});

	// PARAM DETECTION
	if(self[\params].includesKey(\amp)) {
		self[\hasAmp] = true;
		self[\muteAmp] = 0;
	};

	if(self[\params].includesKey(\vol)) {
		self[\hasVol] = true;
		self[\muteVol] = 0;
	};

	if(self[\params].includesKey(\gain)) {
		self[\hasGain] = true;
	};

	if(self[\params].includesKey(\env)) {
		self[\hasEnv] = true;
	};

	if(self[\tunable]) {
		self[\defaultArgs][\freq] = 440;
	};

	self[\args] = self[\defaultArgs].copy;

	self
},

setName: { |self, aString|
	self[\name] = aString;
	self.emitSignal(\_nameChanged);
},

setParam: { |self, symbol, value|
	self[\params][symbol].setValue(value);

	// Reset stopAmp on manual activation
	if(
		(symbol == \amp)
		and:
		self[\stopAmp].notNil
	) {
		self[\stopAmp] = nil;
	};

	self
},

setPlayer: { |self, player|

	self[\player] = player;

	if(self[\hasTempo]) {
		self.setParam(\tempo, player[\bpm]);
		player.connectSignal(
			\_bpmChanged, { |newBPM|
				self.setParam(\tempo, newBPM);
		});
	};

	if(self[\tunable]) {
		self.setFreq(player[\freq]);
		player.connectSignal(
			\_freqChanged, { |newFreq|
				self.setFreq(newFreq);
		});
	};

	self
},

getParam: { |self, symbol|
	self[\params][symbol]
},

//------//
// PLUG //

plugInto: { |self, synth, outParam = \out, inParam = \in|
	var circular;

	// IMPROVE ME:
	// branches are reordered twice:
	// when unplugged, then when plugged
	// in theory, both could
	// be reordered at the same time

	// Chain to synth conversion
	if(synth[\type] == \chain) {
		synth = synth[\source];
	};

	// Check circularity
	circular = [self, List(0), false];
	circular = synth.checkCircularity(circular);

	if(circular[2].not) {
		// Disconnect self from previous out
		if(self[\outPlugs][outParam].notNil) {
			self[\outPlugs][outParam][\synth]
			.unplug(
				self,
				outParam,
				inParam
			);
		};

		// Indicate param isn't plugged externally
		self[\extOutPlugs][outParam] = nil;

		// Reference connection
		self[\outPlugs][outParam] = (
			synth: synth,
			param: inParam
		);

		// Connect self to new synth
		synth.plug(
			self,
			outParam,
			inParam
		);

		// Update synth
		self.setParam(
			outParam,
			synth[\busses][inParam]
		);
	} {
		"circular connection attempt".warn;
	};

},

plugOut: { |self, out, outParam = \out|
	// Indicate param isn't plugged internally
	self[\outPlugs][outParam] = nil;
	self[\extOutPlugs][outParam] = out;
	self.setParam(
		outParam,
		out
	);
},

unplug: { |self, synth, outParam, inParam|
	var index = -1;
	var newGroup = 0;
	if(self[\inPlugs][inParam].notNil) {
		self[\inPlugs][inParam].do({ |plug, plugIndex|
			if(index == -1) {
				if(
					plug[\synth] === synth
					and:
					{ plug[\param] == \outParam }
				) {
					index = plugIndex;
				};
			};
		});
		if(index != -1) {
			self[\inPlugs][inParam].removeAt(index);
			// Notify synth from disconnection
			synth[\outPlugs][outParam] = nil;
			if(self[\inPlugs][inParam].size == 0) {
				self[\inPlugs][inParam] = nil;
			};

			// Check if new group index is different
			self[\inPlugs].do({ |inList|
				if(inList.notNil) {
					inList.do({ |synth|
						if(
							synth[\synth][\group] == self[\group]
							and:
							{ (synth[\synth][\groupIndex] + 1) > newGroup }
						) {
							newGroup = synth[\synth][\groupIndex] + 1;
						};
					});
				};
			});
			if(newGroup != self[\groupIndex]) {
				self.updateBranch;
			};
		};
	};

	self
},

plug: { |self, synth, outParam, inParam|
	var newGroup = 0;

	// Reference input synth
	if(self[\inPlugs][inParam].isNil) {
		self[\inPlugs][inParam] = List(0);
	};
	if(
		self[\inPlugs][inParam]
		.includesEqual(
			(
				synth: synth,
				param: outParam
			)
		).not
	) {
		self[\inPlugs][inParam].add(
			(
				synth: synth,
				param: outParam
			)
		);

		// Check if new group index is different
		self[\inPlugs].do({ |inList|
			if(inList.notNil) {
				inList.do({ |synth|
					if(
						synth[\synth][\group] == self[\group]
						and:
						{ (synth[\synth][\groupIndex] + 1) > newGroup }
					) {
						newGroup = synth[\synth][\groupIndex] + 1;
					};
				});
			};
		});

		if(newGroup != self[\groupIndex]) {
			self.updateBranch;
		};
	} {
		"synth already connected".warn;
	};

	self
},

// Updates self target group,
// then every subsequent node
updateBranch: { |self|
	var branch = self.collectBranch(
		List(0),
		self[\groupIndex] - 1;
	);
	branch.do({ |group|
		group.do({ |synth|
			synth.updateGroupIndex;
		});
	});
},

// Recursively collects the branch,
// grouping nodes by groupIndex
collectBranch: { |self, branch, startingIndex|
	var relativeIndex = self[\groupIndex] - startingIndex;
	while { branch.size < relativeIndex } {
		branch.add(List(0));
	};
	if(branch[relativeIndex - 1].includes(self).not) {
		branch[relativeIndex - 1].add(self)
	};
	self[\outPlugs].do({ |plug|
		if(
			plug.notNil
			and:
			{ plug[\synth][\group] == self[\group] }
		) {
			plug[\synth].collectBranch(branch, startingIndex);
		};
	});
	branch
},

updateGroupIndex: { |self|
	var newIndex = 0;

	// Calculate minimum possible group
	self[\inPlugs].do({ |inList|
		if(inList.notNil) {
			inList.do({ |synth|
				if(
					synth[\synth][\group] == self[\group]
					and:
					{ (synth[\synth][\groupIndex] + 1) > newIndex }
				) {
					newIndex = synth[\synth][\groupIndex] + 1;
				};
			});
		};
	});

	// Find relevant target group
	if(newIndex != self[\groupIndex]) {
		self[\groupIndex] = newIndex;
		switch(self[\group])
		{ \control } {
			while { ~gmDefs[\controlGroups].size < (newIndex + 1) } {
				~gmDefs.addControlGroup;
			};
			self[\target] = ~gmDefs[\controlGroups][newIndex];
		}
		{ \filter } {
			while { ~gmDefs[\filterGroups].size < (newIndex + 1) } {
				~gmDefs.addFilterGroup;
			};
			self[\target] = ~gmDefs[\filterGroups][newIndex];
		};

		// Move synth if ready
		if(self[\ready]) {
			self[\synth].moveToTail(self[\target]);
		};
	};
},

// Checks if synth would end up
// connecting to itself
checkCircularity: { |self, circular|
	self[\outPlugs].keysValuesDo({ |key, plug|
		if(
			circular[2].not
			and:
			{ plug.notNil }
		) {
			if(plug[\synth] != circular[0]) {
				if(circular[1].includes(plug[\synth]).not) {
					circular[1].add(plug[\synth]);
					circular = plug[\synth].checkCircularity(circular);
				};
			} {
				circular[2] = true;
			};
		};
	});
	circular
},

//----------------//
// DUMP UTILITIES //
dumpPairs: { |self|
	"".postln;
	"[".postln;
	(
		"\t"
		++ "\\instrument, \\"
		++ self[\datas][\symbol]
		++ ","
	).postln;

	self[\params].keysValuesDo({ |key, value|
		(
			"\t\\"
			++ key
			++ ", "
			++ value
			++ ","
		).postln;
	});

	"]".postln;
	"".postln;
},
)