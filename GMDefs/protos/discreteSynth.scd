(
init: { |self, datas|
	self.initParent(datas);

	self[\persistent] = false;
	self[\modulatePersistent] = false;

	// DEFAULT OR NOT ?
	/*if(self[\type] == \filePlayer) {
		self.setPersistent(true);
		self.setModulatePersistent(true);
	};*/

	if(self[\tunable]) {
		self[\score] = ~gmDefs.getScaleScore;
		self[\mixFreqs] = true;
		self[\mixFreqsAmp] = 0.75;
	};

	self
},

doPlay: { |self|
	var synth = Synth(
		self[\symbol],
		self[\args].asPairs
	);
	if(self[\persistent]) {
		self.registerSynth(synth);
	};
},

doPlayDefault: { |self|
	var synth = Synth(
		self[\symbol],
		self[\defaultArgs].asPairs
	);
	if(self[\persistent]) {
		self.registerSynth(synth);
	};
},

doPlayFreq: { |self, freq|
	var synth, args;
	args = self[\args].deepCopy;
	if(self[\tunable]) {
		args[\freq] = freq;
	};
	synth = Synth(
		self[\symbol],
		args.asArray
	);
	if(self[\persistent]) {
		self.registerSynth(synth);
	};
},

doPlayAmpFreq: { |self, amp, freq|
	var synth;
	var args = self[\args].deepCopy;
	if(self[\hasAmp]) {
		args[\amp] = amp * self[\args][\amp];
	};
	if(self[\tunable]) {
		args[\freq] = freq;
	};
	synth = Synth(
		self[\symbol],
		args.asPairs
	);
	if(self[\persistent]) {
		self.registerSynth(synth);
	};
},

doPlayBuffer: { |self, buffer|
	var synth, args;
	args = self[\args].deepCopy;
	args[\buffer] = buffer;
	synth = Synth(
		self[\symbol],
		args.asPairs
	);
	if(self[\persistent]) {
		self.registerSynth(synth);
	};
},

doPlayAt: { |self, beat|
	var args, synth;

	args = self[\args].copy;

	self[\params].do({ |param|
		args[param[\symbol]] = param.getAtBeat(beat);
	});

	synth = Synth(
		self[\symbol],
		args.asPairs
	);

	if(self[\persistent]) {
		self.registerSynth(synth);
	};
},

doPlayFreqsAt: { |self, beat, freqs|
	var args, argsCopy, synth, amp;

	amp = 1;
	if(self[\mixFreqs]) {
		freqs.size.do({
			amp = amp * self[\mixFreqsAmp];
		});
	};

	args = self[\args].copy;

	self[\params].do({ |param|
		args[param[\symbol]] = param.getAtBeat(beat);
	});

	freqs.do({ |freq|
		argsCopy = args.copy;
		argsCopy[\amp] = argsCopy[\amp] * amp;
		argsCopy[\freq] = freq;

		synth = Synth(
			self[\symbol],
			argsCopy.asPairs
		);

		if(self[\persistent]) {
			self.registerSynth(synth);
		};
	});
},

modulateSynths: { |self, beat|
	var value, newArgs;
	newArgs = ();

	self[\params].do({ |param|
		param.postln;
		value = param.getAtBeat(beat);
		if(self[\args][param[\symbol]] != value) {
			self[\args][param[\symbol]] = value;
			newArgs[param[\symbol]] = value;
		};
	});

	self[\synths].do({ |synth|
		newArgs.keysValuesDo({ |param, value|
			synth.set(param, value);
		});
	});
},

registerSynth: { |self, synth|
	self[\synths].add(synth);
	synth.onFree({
		self.emitSignal(
			\_synthFree,
			synth
		);
		self[\synths].remove(synth);
	});
},

setFreq: { |self, freq|
	self[\args][\freq] = freq;
},

setPlayer: { |self, player|
	self[\player] = player;
},

bindPlayer: { |self, player|
	self[\player] = player;

	self[\rhythm] = ~gmDefs.getRhythmProto;

	// Trigger and freqs are bound
	// to the default rhythm until overriden
	self[\triggerRhythm] = self[\rhythm];
	if(self[\tunable]) {
		self[\freqRhythm] = self[\rhythm];
		self[\score].setRhythm(self[\freqRhythm]);
		self[\score].setPlayer(self[\player]);
	};

	// Connect size changed signal
	self[\rhythm].connectSignal(
		\_sizeChanged,
		{ |size|
			var defaultTrigger = 0;
			if(self[\tunable]) {
				defaultTrigger = 1;
			};
			self.setTriggers(
				Array.fill(
					size,
					{ defaultTrigger }
				);
			);
		},
		self
	);

	// Setup the rhythm proto
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
		param.setRhythm(self[\rhythm]);
	});

	player.connectSignal(
		\_beat,
		{ |beat|
			var freqs;
			var canPlay = true;
			var time = 0;

			// Modulate persistent
			if(
				self[\modulatePersistent]
				and:
				{ self[\synths].size > 0 }
			) {
				self.modulateSynths(beat);
			};

			if(self[\tunable]) {
				freqs = self[\score].getFreqsAt(beat);
				if(freqs.isNil) {
					canPlay = false;
				};
			};

			if(canPlay) {
				canPlay = false;
				(self[\rhythm][\depth] + 1).do({ |index|
					if(canPlay.not) {
						canPlay = (
							beat[\beatDetection][index]
							== 1
						);
					};
				});

				if(canPlay) {
					time =
					(beat[\absGrid][self[\rhythm][\depth]] - 1)
					+ self[\rhythm][\offset]
					% self[\triggers].size;
					if(self[\triggers][time].coin) {
						if(self[\tunable].not) {
							self.doPlayAt(beat);
						} {
							self.doPlayFreqsAt(beat, freqs);
						};
					};
				};
			};
		},
		self
	);

	if(self[\tunable]) {
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

/////////////
// RHYTHM  //

bindRhythm: { |self, depth = 0, mul = 1, offset = 0|
	if(self[\rhythm].notNil) {
		self[\rhythm].bindRhythm(
			depth,
			mul,
			offset
		);
	};
	self
},

autoBindRhythm: { |self, depth = 0|
	if(self[\rhythm].notNil) {
		self[\rhythm].autoBindRhythm(
			depth
		);
	};
	self
},

unbindRhythm: { |self, depth = 0, size = 0, offset = 0|
	if(self[\rhythm].notNil) {
		self[\rhythm].unbindRhythm(
			depth,
			size,
			offset
		);
	};
	self
},

setTriggers: { |self, newTriggers|
	// FIX ME: update rhythm specifications
	// to match the trigger size
	self[\triggers] = newTriggers.copy;
	self.emitSignal(
		\_triggersChanged,
		self[\triggers]
	);
	self
},

// RHYTHM  //
/////////////

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
		self[\player].rmSignal(
			\remove,
			self[\playerRMFunction]
		);
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

setFreq: { |self, freq|
	if(self[\tunable]) {
		self[\args][\freq] = freq;
		self.emitSignal(\_freqChanged, freq);
	};
},

updateParam: { |self, param, symbol, value|
	if(param[\mode] == \value) {
		if(self[\modulatePersistent]) {
			self[\synths].do({ |synth|
				synth.set(symbol, value);
			});
		};
	};
	self[\args][symbol] = value;
},

updateParamTrack: { |self, param, symbol, value|

},

setGate: { |self, gate|
	if(self[\persistent]) {
		self[\synths].do({ |synth|
			synth.set(\gate, 0);
		});
	};
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

setPersistent: { |self, aBoolean|
	self[\persistent] = aBoolean;
	if(aBoolean) {
		self[\synths] = List(0);
	};
	self
},

setModulatePersistent: { |self, aBoolean|
	if(self[\persistent].not) {
		self[\persistent] = true;
	};
	self[\modulatePersistent] = aBoolean;
	if(self[\synths].isNil) {
		self[\synths] = List(0);
	};
	self
},

/*setFreq: { |self, index, value|
	if(self[\tunable] and: { index < self[\nBeats] }) {
		self[\freqs][index] = value;
		if(self[\player].notNil
			and: { self[\player][\currentBeat] == index })
		{ self.updateMsg; };
	};
},*/

setTempo: { |self, tempo|
	if(self[\hasTempoParam]) {
		self[\tempo] = tempo;
		self.updateMsg;
	};
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
	// Emit remove signal
	self.emitSignal(\_removed);
	self.clear;
},

).parent_(~gmDefs[\synthParent])