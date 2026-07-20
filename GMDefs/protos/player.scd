(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\id] = ~gmDefs.getUID;
	self[\signals] = ();
	self.initFreq;
	self.initRhythm;
	self
},

initFreq: { |self|
	self[\freq] = 440;
	self[\tuning] = 1;
	self[\scale] = \minor;
	self[\note] = "A";
	self[\degree] = "I";
	self[\chord] = "-";
},

initRhythm: { |self|
	self[\bpm] = 60;
	self[\beat] = 0;
	self[\divisions] = [4, 4, 2, 2];
	self[\clock] = TempoClock.tempo_(
		self[\bpm] / 60
	);
	self[\isPlaying] = false;

	self[\routine] = Routine({

		var nSubdivisions = 1;

		self[\beatGrid] = Array.fill(
			self[\divisions].size,
			{ 0 }
		);

		self[\absGrid] = Array.fill(
			self[\divisions].size,
			{ 1 }
		);

		self[\divisions].do({ |div, index|
			if(index > 1) {
				nSubdivisions = nSubdivisions * div;
			};
		});

		self[\beat] = 0;

		self[\beatDetection] = Array.fill(
			self[\divisions].size,
			{ 0 }
		);

		self[\beatDetection][0] = 1;

		loop {
			self[\currentBeat] = (
				beat: self[\beat],
				beatGrid: self[\beatGrid],
				absGrid: self[\absGrid],
				beatDetection: self[\beatDetection],
			);

			self.emitSignal(
				\_preBeat,
				self[\currentBeat]
			);

			self.emitSignal(
				\_beat,
				self[\currentBeat]
			);

			self.emitSignal(
				\_postBeat,
				self[\currentBeat]
			);

			(1 / nSubdivisions).wait;

			self[\beat] = self[\beat] + 1;
			self[\absGrid][self[\absGrid].size - 1]
			= self[\absGrid][self[\absGrid].size - 1] + 1;

			// Increment beat counter
			// starting from the right
			// (smallest time division)

			self[\beatGrid][self[\divisions].size - 1]
			= self[\beatGrid][self[\divisions].size - 1] + 1;

			self[\beatDetection] = Array.fill(
				self[\divisions].size,
				{ 0 }
			);
			self[\beatDetection][self[\divisions].size - 1] = 1;

			self[\beatGrid].size.do({ |index|
				index = self[\beatGrid].size - 1 - index;
				if(self[\beatGrid][index] >= self[\divisions][index]) {
					self[\beatGrid][index]
					= self[\beatGrid][index] - self[\divisions][index];
					// Reset current division detection
					self[\beatDetection][index] = 0;
					if(index > 0) {
						self[\beatGrid][index - 1]
						= self[\beatGrid][index - 1] + 1;
						self[\beatDetection][index - 1] = 1;
						// Increment absolute grid
						self[\absGrid][index - 1] = self[\absGrid][index - 1] + 1;
					};
				};
			});

			// Special first beat detection
			if(self[\beatDetection].sum == 0) {
				self[\beatDetection][0] = 1;
			};
		};
	});
},

setRhythm: { |self, divisions|
	if(self[\divisions] != divisions) {
		self[\divisions] = divisions;
		self.emitSignal(
			\_rhythmChanged,
			self[\divisions]
		);
	};
	self
},

//------//
// FREQ //
setTuningHz: { |self, freq|
	self[\tuning] = freq / 440;
	self.emitSignal(
		\_freqChanged,
		self[\freq] * self[\tuning]
	);
	self
},

setTuning: { |self, tuning|
	self[\tuning] = tuning;
	self.emitSignal(
		\_freqChanged,
		self[\freq] * self[\tuning]
	);
	self
},

setFreq: { |self, freq|
	self[\freq] = freq;
	self.emitSignal(
		\_freqChanged,
		self[\freq] * self[\tuning]
	);
	self
},

setScale: { |self, scale|
	self[\scale] = scale;
	self.emitSignal(
		\_scaleChanged,
		self[\scale]
	);
	self
},

//--------//
// RHYTHM //
setBPM: { |self, bpm|
	self[\bpm] = bpm;
	self[\clock].tempo_(
		self[\bpm] / 60
	);
	self.emitSignal(
		\_bpmChanged,
		self[\bpm]
	);
	self
},

doPlay: { |self|
	if(self[\isPlaying].not) {
		self[\routine]
		.reset
		.play(self[\clock]);
		self[\isPlaying] = true;
		self.emitSignal(\_playing);
	};
},

doStop: { |self|
	if(self[\isPlaying]) {
		self[\routine].stop;
		self[\isPlaying] = false;
		self.emitSignal(\_stopped);
	};
},

getRate: { |self|
	60 / self[\bpm]
},

doRemove: { |self|
	if(self[\clock].isRunning) {
		self[\clock]
		.clear
		.stop;
	};
	self[\routine].stop;
	self.emitSignal(\_removed);
	self.clear;
},
)