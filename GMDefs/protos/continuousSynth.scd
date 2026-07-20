(
init: { |self, datas|
	self.initParent(datas);

	if(self[\tunable]) {
		self[\score] = ~gmDefs.getScaleScore;
		self[\score][\mode] = \monophonic;
	};

	// Start synth
	if(self[\numKernels] == 0) {
		self.doPlay;
	};

	self
},

doPlay: { |self|
	if(self[\synth].isNil) {
		self[\synth] = Synth(
			self[\symbol],
			self[\args].asKeyValuePairs,
			addAction: \addToTail,
		);
		self.emitSignal(\_synthReady);
	};
},

doStop: { |self|
	if(self[\synth].notNil) {
		self[\synth].free;
		self[\synth] = nil;
	};
},

playDefault: { |self|
	if(self[\synth].isNil) {
		Synth(
			self[\symbol],
			self[\defaultArgs].asArray
		);
	};
},

playFreq: { |self, freq|
	var args;
	if(self[\synth].isNil) {
		args = self[\args].deepCopy;
		if(self[\tunable]) {
			args[\freq] = freq;
			self[\args][\freq] = freq;
		};
		Synth(
			self[\symbol],
			args.asArray
		);
		if(self[\tunable]) {
			self.emitSignal(
				\_freqChanged,
				freq
			);
		};
	} {
		self.setFreq(freq);
	};
},

playAmpFreq: { |self, amp, freq|
	var args;
	if(self[\synth].isNil) {
		args = self[\args].deepCopy;
		if(self[\hasAmpParam]) {
			args[\amp] = amp;
		};
		if(self[\tunable]) {
			args[\freq] = freq;
		};
		Synth(
			self[\symbol],
			args.asPairs
		);
	};
},

setFreq: { |self, freq|
	if(self[\tunable]) {
		if(self[\args][\freq] != freq) {
			self[\synth].set(\freq, freq);
			self[\args][\freq] = freq;
			self.emitSignal(\_freqChanged, freq);
		};
	};
},

updateParam: { |self, param, symbol, value|
	if(param[\mode] == \value) {
		if(self[\synth].notNil) {
			self[\synth].set(symbol, value);
		};
	};
	self[\args][symbol] = value;
},

updateParamTrack: { |self, param, symbol, value|

},

bindPlayer: { |self, player|
	self[\player] = player;

	self[\rhythm] = ~gmDefs.getRhythmProto;
	self[\rhythm]
	.setPlayer(player)
	// try to bind depth 2 by default
	.autoBindRhythm(
		min(
			2,
			player[\divisions].size - 1
		)
	);

	// By default,
	// connect params to this rhythm
	self[\params].do({ |param|
		if(param[\type] != \in) {
			param.setRhythm(self[\rhythm]);
		};
	});

	player.connectSignal(
		\_beat,
		{ |beat|
			var freqs, value;

			if(self[\tunable]) {
				freqs = self[\score].getFreqsAt(beat);
				if(freqs.notNil) {
					self.setFreq(freqs[0]);
				};
			};

			self[\params].do({ |param|
				if(
					self[\args].includesKey(param[\symbol])
					and:
					{ param[\type] != \in }
				) {
					value = param.getAtBeat(beat);
					if(self[\args][param[\symbol]] != value) {
						self[\synth].set(param[\symbol], value);
						self[\args][param[\symbol]] = value;
					};
				};
			});
		},
		self
	);

	if(self[\datas][\type] == \synth) {
		player.connectSignal(
			\_playing,
			{
				if(self[\stopAmp].notNil) {
					self.setParam(\amp, self[\stopAmp]);
				};
			},
			self
		);

		player.connectSignal(
			\_stopped,
			{
				self[\stopAmp] = self[\args][\amp];
				self.setParam(\amp, 0);
			},
			self
		);
	};

	if(self[\paramsByType][\tempo].size > 0) {
		self[\paramsByType][\tempo].do({ |param|
			param.setRate(player.getRate);
		});
		player.connectSignal(
			\_bpmChanged,
			{
				self[\paramsByType][\tempo].do({ |param|
					param.setRate(player.getRate);
				});
			},
			self
		);
	};

	if(self[\tunable]) {
		self[\freqRhythm] = self[\rhythm];
		self[\score].setRhythm(self[\freqRhythm]);
		self[\score].setPlayer(self[\player]);
		player.connectSignal(
			\_freqChanged,
			{ |freq|
				self.setFreq(freq);
			},
			self
		);
	};

	self
},

disconnectPlayer: { |self|
	var oldMsgs;
	if(self[\player].notNil) {
		// Update player
		if(self[\currentMsgs].notNil) {
			oldMsgs = self[\currentMsgs].deepCopy;
		} {
			oldMsgs = nil;
		};
		self[\player].notifyMsgsChange(oldMsgs, nil);
		if(oldMsgs.notNil) {
			oldMsgs.clear;
		};
		self[\player][\discreteSynths].remove(self);
		self[\player][\synths].remove(self);
		self[\player].rmSignal(\remove, self[\playerRMFunction]);
		self[\playerRMFunction] = nil;
		// Update self
		self[\player] = nil;
	};
},

audibleAt: { |self, time|
	var audible = true;
	if(self[\hasAmpParam]) {
		audible = self[\muted].not;
	};
	if(audible) {
		time = time%self[\nBeats];
		audible = self[\triggers][time].coin;
	};
	if(audible) {
		if(self[\hasAmpParam]
			and: { self[\track][time][\amp] == 0 }) {
			audible = false;
		};
	};
	if(audible) {
		if(self[\tunable]
			and: { self[\freqs][time] == nil; }) {
			audible = false;
		};
	};
	audible
},

getMsgAt: { |self, time|
	// FIX ME: SHOULD ONLY CHANGE CONTROLS THAT ACTUALLY CHANGED
	var msgs = nil;
	var oscMsg = self[\header].deepCopy.asList;
	time = time%self[\nBeats];
	msgs = List(0);
	// Fill params
	self[\track][time].keysValuesDo({ |symbol, value|
		oscMsg.add(symbol);
		switch(self[\datas][\param][symbol][\type])

		{ \env } {
			oscMsg.add($[);
			value.asControlInput.do({ |segment|
				oscMsg.add(segment); });
			oscMsg.add($]);
		}

		{ \timeTempo } {
			oscMsg.add(
				(self[\tempo] / 60)
				* value.reciprocal
			);
		}

		{ \freqTempo } {
			oscMsg.add(
				(self[\tempo] / 60)
				* value
			);
		}

		{
			// Special case, polyphonic mixer
			if(
				(symbol == \amp)
				and: {
					self[\tunable]
					and: { self[\mixFreqs] }
				}
			) { self[\freqs][time].size.do({
				value = value * 0.8;
			}); };
			oscMsg.add(value);
		};
	});
	// Out param
	oscMsg.add(\out);
	oscMsg.add(self[\out]);
	// Frequency management
	if(self[\tunable]) {
		self[\freqs][time].do({ |freq|
			var msg = oscMsg.deepCopy;
			msg.add(\freq);
			if(self[\player].notNil)
			{ msg.add(self[\player].getFreqAtIndex(freq)); }
			{ msg.add(freq); };
			msgs.add(msg.asArray);
			msg.clear;
		});
	} {
		// Needs to be an Array
		msgs.add(oscMsg.asArray);
	};
	oscMsg.clear;
	msgs
},

getScoreAt: { |self, time|
	var msgs = nil;
	if(self.audibleAt(time))
	{ msgs = self.getMsgAt(time); };
	// Update cached msgs
	if(self[\currentMsgs].notNil)
	{ self[\currentMsgs].clear; };
	if(msgs.notNil)
	{ self[\currentMsgs] = msgs.deepCopy; }
	{ self[\currentMsgs] = nil; };
	// Return
	msgs
},

playAt: { |self, time|
	var msgs = self.getMsgAt(time);
	if(msgs.notNil) {
		~gmDefs[\server].listSendBundle(
			0,
			msgs
		);
		msgs.clear;
	};
},

generateHeader: { |self|
	self[\header] = List(0);
	self[\group] = ~gmDefs[\server].defaultGroupID;
	if(self[\player].notNil) {
		self[\group] = self[\player][\discreteGroup].nodeID;
	};
	self[\header].clear;
	self[\header].add(\s_new);
	self[\header].add(self[\datas][\symbol]);
	self[\header].add(-1);
	self[\header].add(0);
	self[\header].add(self[\group]);
},

// Player holds osc msgs ready one beat in advance.
// If a modification impacts the msg it currently holds,
// (i. e. user modified current cached osc msg)
// we notify it to update its score.
updateMsg: { |self|
	var oldMsgs, newMsgs;
	if(self[\player].notNil) {
		if(self[\currentMsgs].notNil) {
			oldMsgs = self[\currentMsgs].deepCopy; } {
			oldMsgs = nil;
		};
		newMsgs = self.getScoreAt(self[\player][\currentBeat]);
		self[\player].notifyMsgsChange(oldMsgs, newMsgs);
		if(oldMsgs.notNil) {
			oldMsgs.clear;
		};
	};
},

setMuted: { |self, aBoolean|
	self[\muted] = aBoolean;
	self.updateMsg;
	self.emitSignal(\mute);
},

setTrackParam: { |self, symbol, index, value|
	if(index < self[\nBeats]) {
		if(index == -1) {
			self[\params][symbol] = value;
			self[\track].do({ |beat|
				beat[symbol] = value;
			});
			self.updateMsg;
		} {
			self[\track][index][symbol] = value;
			if(self[\player].notNil
				and: { self[\player][\currentBeat] == index })
			{ self.updateMsg; };
		};
		self.emitSignal(symbol);
	};
},

setMode: { |self, symbol, mode|
	self[\paramsModes][symbol] = mode;
	if(mode == \value) {
		self.setParam(
			symbol,
			-1,
			self[\params][symbol]
		);
	};
	self.emitSignal(symbol);
},

setTrigger: { |self, index, value|
	if(index < self[\nBeats]) {
		self[\triggers][index] = value;
		if(self[\player].notNil
			and: { self[\player][\currentBeat] == index })
		{ self.updateMsg; };
	};
	self.emitSignal(\trigger);
},

setMasterOut: { |self, data|
	self[\out] = data[\bus].index;
},

setEffectOut: { |self, data|
	self[\out] = data[\bus].index;
	data.addInSynth(self);
},

setOut: { |self, data|
	// Remove self from current effect if needed
	if(self[\outNode].notNil) {
		if(self[\outNode][\type] == \effect) {
			self[\outNode].removeInSynth(self);
		};
	};
	switch(data[\type])
	{ \master } { self.setMasterOut(data); }
	{ \effect } { self.setEffectOut(data); };
	self.updateMsg;
	self[\outNode] = data;
	self.emitSignal(\out);
},

setMaxBeat: { |self, maxBeat|
	if(self[\nBeats] != maxBeat) {
		self[\nBeats] = maxBeat;
		if(self[\trigger].size < self[\nBeats]) {
			while { self[\triggers].size < self[\nBeats] } {
				if(self[\tunable]) {
					self[\triggers].add(1);
				} {
					self[\triggers].add(0);
				};
				self[\freqs].add(nil);
			};
		} {
			while { self[\triggers].size > self[\nBeats] } {
				self[\triggers].pop;
				self[\freqs].pop;
			};
		};
		self.resizeTrack;
		self.updateMsg;
	};
},

setMixFreqs: { |self, aBoolean|
	self[\mixFreqs] = aBoolean;
	self.updateMsg;
	self.emitSignal(\mixFreqs);
},

updateKernel: { |self, filePath, symbol, iteration = 0|
	if(self[\args][symbol].notNil) {
		self[\args][symbol].read(
			filePath,
			action: {
				self[\synth].set(\kernelUpdate, 0);
				self[\synth].set(\kernelUpdate, 1);
			}
		);
	} {
		if(iteration < 20) {
			{
				self.updateKernel(
					filePath,
					symbol,
					iteration + 1;
				);
			}.defer(0.1);
		} {
			"Failed to load kernel".warn;
		};
	};
	self
},

// /!\ WIP: Out not saved for now
getSaveData: { |self, dataName|
	var data = ();
	data[\name] = dataName;
	[
		\nBeats,
		\triggers,
		\params,
		\track,
		\paramsModes,
	].do({ |symbol|
		data[symbol] = self[symbol].deepCopy;
	});

	if(self[\tunable]) {
		[
			\freqs,
			\mixFreqs
		].do({ |symbol|
			data[symbol] = self[symbol].deepCopy;
		});
	};

	data
},

loadData: { |self, data|
	[
		\nBeats,
		\triggers,
		\params,
		\track,
		\paramsModes,
	].do({ |symbol|
		self[symbol].clear;
		self[symbol] = data[symbol].deepCopy;
		data[symbol].clear;
	});
	if(self[\tunable]) {
		[
			\freqs,
			\mixFreqs
		].do({ |symbol|
			self[symbol].clear;
			self[symbol] = data[symbol].deepCopy;
			data[symbol].clear;
		});
	};
	// Adapt to current rythm
	// (temporary)
	if(self[\player].notNil) {
		self.setMaxBeat(self[\player][\nBeats]);
	};
	self.updateMsg;
	// Ask UI update
	self.emitSignal(\trigger);
	self.emitSignal(\freqs);
	self.emitSignal(\nBeats);
	self[\params].keysDo({ |symbol|
		self.emitSignal(symbol); });
	self.emitSignal(\mixFreqs);
	data.clear;
},

constructTrack: { |self|
	self[\triggers] = List(0);
	if(self[\tunable]) {
		self[\freqs] = List(0);
	};
	self[\defaultTrack] = self[\params].deepCopy;
	self[\nBeats].do({
		self[\track].add(self[\defaultTrack].deepCopy);
		if(self[\tunable]) {
			// if synth is tunable, triggers can be set to one
			// cause nil frequencies still mute the synth
			self[\freqs].add(nil);
			self[\triggers].add(1);
		} {
			self[\triggers].add(0);
		};
	});
},

resizeTrack: { |self|
	if(self[\track].size < self[\nBeats]) {
		while { self[\track].size < self[\nBeats] } {
			self[\track].add(self[\defaultTrack].deepCopy);
		};
	} {
		while { self[\track].size > self[\nBeats] } {
			self[\track].pop;
		};
	};
},

doRemove: { |self|
	self.disconnectPlayer;
	if(self[\synth].notNil) {
		self[\synth].free;
	};
	// Emit remove signal
	self.emitSignal(\_removed);
	self.clear;
},
).parent_(~gmDefs[\synthParent])