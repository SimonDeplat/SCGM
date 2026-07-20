(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\score] = nil;
	self[\xOffset] = 0;
	self[\yOffset] = 0;
	self[\scaleSize] = 0;
	self[\xSize] = 0;
	self[\ySize] = 0;
	self[\indexScore] = nil;
	self[\displayedScore] = nil;

	self[\pianoRoll] = ~gmWidgets.getPianoRoll
	.beat(0)
	.connectSignal(
		\_scoreChanged,
		{ |score|
			self.updateScore(
				score[\index],
				score[\values]
			);
		},
		self
	);

	self[\menu] = ~gmWidgets.getMenu;
	self[\copyButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\copy))
	.connectSignal(
		\_buttonPressed,
		{
			if(self[\score].notNil) {
				~gmDefs.doCopy(
					\score,
					self[\score]
				);
			};
		},
		self
	);
	self[\pasteButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\paste))
	.connectSignal(
		\_buttonPressed,
		{
			if(
				self[\score].notNil
				and:
				{ ~gmDefs[\copyPaste][\score].notNil }
			) {
				self[\score].doCopy(
					~gmDefs[\copyPaste][\score]
				);
			};
		},
		self
	);
	self[\saveButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\saveAs))
	.connectSignal(
		\_buttonPressed,
		{
			var dialog = FileDialog(
				{ |file|
					if(PathName(file).extension != "gmscore") {
						file = file ++ ".gmscore";
					};
					self[\score].doSave(file);
					~gmWidgets[\saveDirectory] =
					PathName(file).pathOnly;
				},
				{ },
				1,
				1,
				true,
				~gmWidgets[\saveDirectory]
			);
		},
		self
	);
	self[\loadButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\load))
	.connectSignal(
		\_buttonPressed,
		{
			var dialog = FileDialog(
				{ |file|
					file.postln;
					PathName(file).extension.postln;
					if(PathName(file).extension == "gmscore") {
						self[\score].doLoad(file);
						~gmWidgets[\loadDirectory] =
						PathName(file).pathOnly;
					};
				},
				{ },
				1,
				0,
				true,
				~gmWidgets[\loadDirectory]
			);
		},
		self
	);

	self[\yMenu] = ~gmWidgets.getMenu;
	self[\incScaleYButton] = self[\yMenu].addButton
	.svg(~gmWidgets.getIcon(\doubleArrowTop))
	.connectSignal(
		\_buttonPressed,
		{
			self[\yOffset] = min(
				self[\yOffset] + self[\scaleSize],
				(self[\scaleSize] * 10) - self[\scaleSize]
			);
			self.displayScore;
		},
		self
	);
	self[\incYButton] = self[\yMenu].addButton
	.svg(~gmWidgets.getIcon(\arrowTop))
	.connectSignal(
		\_buttonPressed,
		{
			if(
				self[\yOffset] <
				((self[\scaleSize] * 10) - self[\scaleSize])
			) {
				self[\yOffset] = self[\yOffset] + 1;
				self.displayScore;
			};
		},
		self
	);
	self[\octaveDisplay] = self[\yMenu].addText;
	self[\octaveDisplay].string(
		(
			self[\yOffset]
			.trunc(self[\scaleSize])
			/ self[\scaleSize]
		)
		.asInteger
		.asString
	);
	self[\decYButton] = self[\yMenu].addButton
	.svg(~gmWidgets.getIcon(\arrowBot))
	.connectSignal(
		\_buttonPressed,
		{
			if(self[\yOffset] > 0) {
				self[\yOffset] = self[\yOffset] - 1;
				self.displayScore;
			};
		},
		self
	);
	self[\decScaleYButton] = self[\yMenu].addButton
	.svg(~gmWidgets.getIcon(\doubleArrowBot))
	.connectSignal(
		\_buttonPressed,
		{
			self[\yOffset] = max(
				self[\yOffset] - self[\scaleSize],
				0
			);
			self.displayScore;
		},
		self
	);

	self[\view] = UserView()
	.layout_(
		HLayout()
		.margins_(0)
		.spacing_(0)
		.add(self[\menu][\view], 1)
		.add(self[\pianoRoll][\view], 8)
		.add(self[\yMenu][\view], 1)
	);

	self
},

setPlayer: { |self, player|
	if(self[\player] != player) {
		if(self[\player].notNil) {
			self[\player].disconnectNode(self);
		};

		self[\player] = player;

		player.connectSignal(
			\_postBeat,
			{ |beat|
				var canPlay = false;
				var beatIndex;
				if(self[\score].notNil) {
					(self[\score][\rhythm][\depth] + 1).do({ |index|
						if(canPlay.not) {
							canPlay = (
								beat[\beatDetection][index]
								== 1
							);
						};
					});
					if(canPlay) {
						beatIndex =
						(beat[\absGrid][self[\score][\rhythm][\depth]] - 1)
						+ self[\score][\rhythm][\offset]
						% self[\score][\indicesScore].size;

						self[\pianoRoll].beat(beatIndex);
					};
				};
			},
			self
		);

		player.connectSignal(
			\_stopped,
			// FIX ME: OFFSET
			{ self[\pianoRoll].beat(0); },
			self
		);
	};

	self
},

setScore: { |self, score|
	if(self[\score] != score) {
		if(self[\score].notNil) {
			self[\score].disconnectNode(self);
			self[\score][\rhythm].disconnectNode(self);
		};
		self[\score] = score;

		if(score[\scale].notNil) {

			if(
				self[\scaleSize]
				!= Scale.at(score[\scale]).ratios.size
			) {
				self[\scaleSize] = Scale.at(score[\scale]).ratios.size;
				self[\ySize] = self[\scaleSize] + 1;
				self.updateVHighlights;
				self[\yOffset] = self[\scaleSize] * 4;
				self[\pianoRoll].entries(
					Array.fill(
						self[\ySize],
						{ |i| i }
					);
				);
			};

			if(score[\indicesScore].notNil) {
				// FIX ME: ZOOM
				self[\xSize] = score[\indicesScore].size;
				self.displayScore(score[\indicesScore]);
			};
		};

		score.connectSignal(
			\_indicesScoreChanged,
			{ |score|
				self[\indexScore] = score;
				// FIX ME
				self[\xSize] = score.size;
				self.displayScore(score);
			},
			self
		);

		// HIGHLIGHTS
		score[\rhythm].connectSignal(
			\_highlights,
			{ |highlights|
				self[\pianoRoll].highlights(
					score[\rhythm][\highlights]
				);
			},
			self
		);

		self[\pianoRoll].highlights(
			score[\rhythm][\highlights]
		);
	};

	self
},

displayScore: { |self, score|
	var indices;

	// score display
	self[\displayedScore] = Array.fill(
		self[\xSize],
		{ nil }
	);

	self[\indexScore].do({ |values, time|
		if(
			time >= self[\xOffset]
			and:
			{ time < (self[\xOffset] + self[\xSize]) }
		) {
			if(values.notNil) {
				indices = values.select({ |value|
					(value >= self[\yOffset])
					and:
					{ value < (self[\yOffset] + self[\ySize]) }
				});
				if(indices.size > 0) {
					self[\displayedScore][time - self[\xOffset]]
					= indices - self[\yOffset];
				};
			};
		};
	});

	self[\pianoRoll].setValues(self[\displayedScore]);

	// vHighlights
	if(self[\vHighlights].notNil) {
		self[\pianoRoll].vHighlights(
			Array.fill(
				self[\ySize],
				{ |i|
					self[\vHighlights][
						(i + self[\yOffset])
						% self[\vHighlights].size
					]
				};
			)
		);
	};

	// octave display
	self[\octaveDisplay].string(
		(
			self[\yOffset]
			.trunc(self[\scaleSize])
			/ self[\scaleSize]
		)
		.asInteger
		.asString
	);
},

updateScore: { |self, index, values|
	var newIndex;
	if(self[\score].notNil) {
		if(values.notNil) {
			if(self[\displayedScore][index].isNil) {
				self[\score].addIndex(
					values[0] + self[\yOffset],
					index + self[\xOffset]
				);
			} {
				if(values.size > self[\displayedScore][index].size) {
					newIndex = values.select({ |value|
						self[\displayedScore][index]
						.includesEqual(value)
						.not
					});
					self[\score].addIndex(
						newIndex[0] + self[\yOffset],
						index + self[\xOffset]
					);
				} {
					newIndex = self[\displayedScore][index].select({ |value|
						values.includesEqual(value).not
					});
					self[\score].removeIndex(
						newIndex[0] + self[\yOffset],
						index + self[\xOffset]
					);
				};
			};
		} {
			self[\score].removeIndex(
				self[\displayedScore][index][0] + self[\yOffset],
				index + self[\xOffset]
			);
		};
	};
},

visible: { |self, visible|
	self[\view].visible_(visible);
	self
},

updateVHighlights: { |self|
	switch(self[\scaleSize])
	{ nil } {
		self[\vHighlights] = nil;
	}
	{ 5 } {
		self[\vHighlights] = [0.7, 0.4, 0, 0.55, 0];
	}
	{ 7 } {
		self[\vHighlights] = [0.7, 0, 0.4, 0, 0.55, 0, 0];
	}
	{ 12 } {
		self[\vHighlights] = [
			0.7, 0, 0,
			0.4, 0.4, 0, 0,
			0.55, 0, 0, 0, 0
		];
	};
},

setStyles: { |self, style, textStyle, widgetStyle|
	self[\pianoRoll].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\menu].setStyles(
		style,
		textStyle,
		widgetStyle
	);
	self[\yMenu].setStyles(
		style,
		textStyle,
		widgetStyle
	);
},
)