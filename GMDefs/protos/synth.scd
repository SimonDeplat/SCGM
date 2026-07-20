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