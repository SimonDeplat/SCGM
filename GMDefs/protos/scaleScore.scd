(
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\id] = ~gmDefs.getUID;
	self[\type] = \scaleScore;

	self[\mode] = \polyphonic;
	self[\player] = nil;
	self[\freq] = 440;
	self[\scale] = nil;
	self[\rhythm] = nil;
	self[\ratios] = nil;
	self[\indicesScore] = nil;
	self[\ratiosScore] = nil;
	self[\freqsScore] = nil;

	self
},

setPlayer: { |self, player|
	if(self[\player].notNil) {
		self[\player].disconnectNode(self);
	};

	self[\player] = player;

	self.setFreq(player[\freq]);
	self.setScale(player[\scale]);

	player.connectSignal(
		\_freqChanged,
		{ |freq| self.setFreq(freq) },
		self
	);

	player.connectSignal(
		\_scaleChanged,
		{ |scale| self.setScale(scale) },
		self
	);

	self
},

setFreq: { |self, freq|
	if(self[\freq] != freq) {
		self[\freq] = freq;
		self.updateFreqsScore;
	};

	self
},

setScale: { |self, scale|
	var ratios;

	if(self[\scale] != scale) {
		self[\scale] = scale;

		ratios = Scale.at(scale).ratios;

		self[\ratios] = [];

		10.do({ |index|
			self[\ratios] =
			self[\ratios] ++ (ratios * 2.pow(index) / 16);
		});
	};

	self.updateRatiosScore;
	self.updateFreqsScore;

	self.emitSignal(
		\_scaleChanged,
		self[\scale]
	);

	self
},

setRhythm: { |self, rhythm|
	if(self[\rhythm].notNil) {
		self[\rhythm].disconnectNode(self);
	};

	self[\rhythm] = rhythm;

	self.resetScores(rhythm[\size]);

	rhythm.connectSignal(
		\_sizeChanged,
		{ |size| self.resetScores(size); },
		self
	);

	self
},

resetScores: { |self, size|
	self[\indicesScore] = Array.fill(
		size,
		{ nil }
	);

	self.emitSignal(
		\_indicesScoreChanged,
		self[\indicesScore]
	);

	self[\ratiosScore] = Array.fill(
		size,
		{ nil }
	);

	self.emitSignal(
		\_ratiosScoreChanged,
		self[\ratiosScore]
	);

	self[\freqsScore] = Array.fill(
		size,
		{ nil }
	);

	self.emitSignal(
		\_freqsScoreChanged,
		self[\freqsScore]
	);
},

updateRatiosScore: { |self|
	var currentIndices;

	self[\ratiosScore] = Array.fill(
		self[\indicesScore].size,
		{ nil }
	);

	self[\indicesScore].do({ |indices, index|
		if(indices.notNil) {
			self[\ratiosScore][index] = Array.fill(
				indices.size,
				{ |i| self[\ratios][indices[i]] }
			);
		};
	});

	self.emitSignal(
		\_ratiosScoreChanged,
		self[\ratiosScore]
	);
},

updateFreqsScore: { |self|
	self[\freqsScore] = Array.fill(
		self[\ratiosScore].size,
		{ nil }
	);

	self[\ratiosScore].do({ |ratios, index|
		if(ratios.notNil) {
			self[\freqsScore][index] = ratios * self[\freq];
		};
	});

	self.emitSignal(
		\_freqsScoreChanged,
		self[\freqsScore]
	);
},

addIndex: { |self, index, time|
	if(self[\mode] == \monophonic) {
		self[\indicesScore][time] = [index];
	} {
		if(self[\indicesScore][time].isNil) {
			self[\indicesScore][time] = [index];
		} {
			if(
				self[\indicesScore][time]
				.includesEqual(index)
				.not
			) {
				self[\indicesScore][time] =
				self[\indicesScore][time] ++ [index]
			};
		};
	};

	self.emitSignal(
		\_indicesScoreChanged,
		self[\indicesScore]
	);

	self.updateRatiosScore;
	self.updateFreqsScore;
},

removeIndex: { |self, index, time|
	if(self[\indicesScore][time].notNil) {
		self[\indicesScore][time]
		.remove(index);
		if(self[\indicesScore][time].size == 0) {
			self[\indicesScore][time] = nil;
		};
	};

	self.emitSignal(
		\_indicesScoreChanged,
		self[\indicesScore]
	);

	self.updateRatiosScore;
	self.updateFreqsScore;
},

getFreqsAt: { |self, beat|
	var freqs = nil;

	if(self[\rhythm].notNil) {
		freqs = self[\freqsScore][
			(beat[\absGrid][self[\rhythm][\depth]] - 1)
			+ self[\rhythm][\offset]
			% self[\freqsScore].size;
		]
	};
	freqs
},

doCopy: { |self, score|
	if(score != self) {
		// Copy rhythm first
		self[\rhythm].doCopy(score[\rhythm]);
		self.setFreq(score[\freq]);
		self.setScale(score[\scale]);
		self[\indicesScore] = score[\indicesScore].copy;
		// Monophonic conversion
		if(self[\mode] == \monophonic) {
			self[\indicesScore].do({ |value, index|
				if(
					value.notNil
					and:
					{ value.size > 1 }
				) {
					self[\indicesScore][index] =
					[value.last];
				};
			});
		};
		self.emitSignal(
			\_indicesScoreChanged,
			self[\indicesScore]
		);
		self.updateRatiosScore;
		self.updateFreqsScore;
	};
},

doSave: { |self, path|
	var file, datas;

	datas = (
		indicesScore: self[\indicesScore],
		scale: self[\scale],
	);

	datas[\version] = ~gmDefs[\version];
	datas[\rhythm] = self[\rhythm].getSaveDatas;

	file = File(
		path.standardizePath,
		"w"
	);

	file.write(datas.asCompileString);
	file.close;
},

doLoad: { |self, path|
	var datas = this.executeFile(path);
	if(
		datas[\rhythm][\divisions]
		== self[\player][\divisions])
	{
		self[\rhythm].setOffset(datas[\rhythm][\offset]);
		self[\rhythm].setDepth(datas[\rhythm][\depth]);
		self[\rhythm].setMul(datas[\rhythm][\mul]);
		self.setScale(datas[\scale]);
		self[\indicesScore] = datas[\indicesScore].copy;
		// Monophonic conversion
		if(self[\mode] == \monophonic) {
			self[\indicesScore].do({ |value, index|
				if(
					value.notNil
					and:
					{ value.size > 1 }
				) {
					self[\indicesScore][index] =
					[value.last];
				};
			});
		};
		self.emitSignal(
			\_indicesScoreChanged,
			self[\indicesScore]
		);
		self.updateRatiosScore;
		self.updateFreqsScore;
	} {
		(
			"File rhythm differs from current player.\n"
			++
			"Implicit conversion is currently unsupported.\n"
			++
			"Aborting, sorry."
		).warn;
	};
},
)