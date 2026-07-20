(
~gmDefs = (
	init: { |self|
		self[\folder] = thisProcess.nowExecutingPath.dirname;
		self[\server] = Server.default;
		self[\scaleNames] = this.executeFile(
			self[\folder] ++ "/collections/scaleNames.scd"
		);
		self.loadGMDefs;
		self.loadConstructors;
		self
	},

	version: "1.0.0-beta",

	//-----------------//
	//    SYNTHDEFS    //

	gmDefs: (),
	gmDefsByCat: (),
	gmDefsByType: (),

	loadGMDef: { |self, datas|

		var params = ();

		// Fill \datas if nil
		// Create sorting keys
		if(datas.includesKey(\type).not) {
			datas[\type] = \uncategorized;
		};
		if((self[\gmDefsByType].includesKey(datas[\type])).not) {
			self[\gmDefsByType][datas[\type]] = List(0);
		};
		self[\gmDefsByType][datas[\type]].add(datas);

		if(datas.includesKey(\category).not) {
			datas[\category] = \uncategorized;
		};
		if((self[\gmDefsByCat].includesKey(datas[\category])).not) {
			self[\gmDefsByCat][datas[\category]] = List(0);
		};
		self[\gmDefsByCat][datas[\category]].add(datas);

		// Allow param access by symbol key
		datas[\params].do({ |param, index|
			params[param[\symbol]] = param;
			params[param[\symbol]][\index] = index;
		});
		datas[\params] = params;

		// Reference datas
		self[\gmDefs][datas[\name].asSymbol] = datas;
	},

	loadGMDefs: { |self|
		// Load synth datas
		PathName(self[\folder] ++ "/SynthDefs/").files.do({ |fileName|
			self.loadGMDef(
				this.executeFile(fileName.fullPath);
			);

		});
	},

	//----------------------//
	//    SYNTH CREATION    //

	synths: (),
	getSynth: { |self, gmDefName|
		var synth = ();
		var datas;

		// Symbol conversion
		// to allow user access by string
		gmDefName = gmDefName.asSymbol;

		datas = self[\gmDefs][gmDefName];

		if(datas.notNil) {

			switch(self[\gmDefs][gmDefName][\emission])

			{ \continuous } {
				synth.parent_(self[\continuousSynth]);
			}

			{ \discrete } {
				synth.parent_(self[\discreteSynth]);
			};

			synth.init(datas);

			self[\synths][synth[\id]] = self;

			synth.connectSignal(
				\_removed,
				self[\synths].removeAt(synth[\id])
			);
		} {
			(
				"GMDefs: "
				++ gmDefName.asString
				++ " not found."
			).warn;
		};

		synth
	},

	//--------------------//
	//    CONSTRUCTORS    //

	getInstance: { |self, parent|
		var instance = ();
		instance.parent_(self[parent]);
		instance.init;
		instance
	},

	loadConstructors: { |self|
		self[\ioManager] = this.executeFile(
			self[\folder] ++ "/protos/ioManager.scd");
		self[\synthParent] = this.executeFile(
			self[\folder] ++ "/protos/synth.scd");
		self[\continuousSynth] = this.executeFile(
			self[\folder] ++ "/protos/continuousSynth.scd");
		self[\discreteSynth] = this.executeFile(
			self[\folder] ++ "/protos/discreteSynth.scd");

		[
			// ABSTRACT
			[\getChain, \chain, "/protos/chain.scd"],
			[\getPlayer, \player, "/protos/player.scd"],

			// PARAMS
			[\getDiscreteParam, \discreteParam,
				"/protos/discreteParam.scd"],
			[\getContinuousParam, \continuousParam,
				"/protos/continuousParam.scd"],
			[\getMultiContinuousParam, \multiContinuousParam,
				"/protos/multiContinuousParam.scd"],
			[\getEnvParam, \envParam,
				"/protos/envParam.scd"],
			[\getTempoParam, \tempoParam,
				"/protos/tempoParam.scd"],
			[\getBufferParam, \bufferParam,
				"/protos/bufferParam.scd"],

			// MISC
			[\getRhythmProto, \rhythmProto,
				"/protos/rhythmProto.scd"],
			[\getScaleScore, \scaleScore,
				"/protos/scaleScore.scd"],

		].do({ |array|
			self[array[0]] = {
				self[array[1]] = this.executeFile(
					self[\folder]
					++ array[2]
				);
				self[array[0]] = {
					self.getInstance(array[1]);
				};
				self.getInstance(array[1])
			};
		});
	},

	//---------------//
	//    SIGNALS    //

	signalsParent: (
		emitSignal: { |self, symbol, args = nil|
			// Triggers registered function on call
			if(self[\signals].includesKey(symbol)) {
				if(args.isNil) {
					self[\signals][symbol].value;
				} {
					self[\signals][symbol].value(args);
				};
			};
		},

		connectSignal: { |self, symbol, function, node = nil|
			// Create the FunctionList if needed
			if(self[\signals].includesKey(symbol).not) {
				self[\signals][symbol] = FunctionList();
			};
			// Register the function
			self[\signals][symbol].addFunc(function);
			// Register node for easy disconnection
			if(node.notNil) {
				if(self[\nodes].includesKey(node).not) {
					self[\nodes][node] = List(0);
					if(node.includesKey(\hasSignals)) {
						node.connectSignal(
							\_removed,
							{ self.disconnectNode(node); },
							self
						);
					};
				};
				self[\nodes][node].add(
					(
						symbol: symbol,
						function: function
					)
				);
			};
			// Return self
			self
		},

		connectOnce: { |self, symbol, function|
			var func = { |args|
				if(args.isNil) {
					function.value;
				} {
					function.value(args);
				};
				self.disconnectSignal(
					symbol,
					func
				);
			};
			self.connectSignal(
				symbol,
				func
			);
			self
		},

		disconnectSignal: { |self, symbol, function|
			if(self[\signals].includesKey(symbol)) {
				self[\signals][symbol].removeFunc(function);
			};
		},

		disconnectNode: { |self, node|
			// Allows to disconnect
			// every connected function at once
			if(self[\nodes].includesKey(node)) {
				self[\nodes][node].do({ |signal|
					self[\signals][signal[\symbol]]
					.removeFunc(signal[\function]);
				});
			};
			self[\nodes].removeAt(node);
		},

		clearSignal: { |self, symbol|
			self[\signals].removeAt(symbol);
		},

		clearAllSignals: { |self|
			var signals = List(0);
			self[\signals].keysDo({ |symbol|
				signals.add(symbol);
			});
			signals.do({ |symbol|
				self[\signals].removeAt(symbol);
			});
		},
	),

	implSignals: { |self, node|
		var currentParent, hasSignals;

		node[\hasSignals] = true;
		node[\signals] = ();
		node[\nodes] = ();

		// We need to check if the node
		// already 'inherits' from signals
		// the node might not directly
		// but one of its parent might
		currentParent = node.parent;
		hasSignals = false;
		while { (
			currentParent.notNil
			and: { hasSignals == false }
		) } {
			hasSignals = (currentParent === self[\signalsParent]);
			currentParent = currentParent.parent;
		};

		// If node doesn't inherit from signals yet,
		// we place the ID on top of the tree
		// to avoid circular references
		if(hasSignals.not) {
			node.insertParent(
				self[\signalsParent],
				inf,
				inf
			);
		};
	},

	//----------------------//
	//    DUMP UTILITIES    //

	dumpSynths: { |self|
		"GMDefs: available synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			"\\".post;
			value[\name].postln;
		});
	},

	dumpContinuousSynths: { |self|
		"GMDefs: continuous synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \continuous) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpDiscreteSynths: { |self|
		"GMDefs: discrete synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \discrete) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpEffectSynths: { |self|
		"GMDefs: effect synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \effect) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpInputSynths: { |self|
		"GMDefs: input synths:".postln;
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value[\type] == \input) {
				"\\".post;
				value[\name].postln;
			};
		});
	},

	dumpSynthsByType: { |self|
		self.dumpContinuousSynths;
		self.dumpDiscreteSynths;
		self.dumpEffectSynths;
		self.dumpInputSynths;
	},

	dumpSynthsByCategory: { |self|
		var categories = ();
		var noCategory = List(0);
		self[\gmDefs].keysValuesDo({ |key, value|
			if(value.includesKey(\category)) {
				if(categories.includesKey(value[\category]).not)
				{ categories[value[\category]] = List(0); };
				categories[value[\category]].add(value[\name]);
			} {
				noCategory.add(value[\name]);
			};
		});
		categories.keysValuesDo({ |key, value|
			"GMDefs: ".post;
			key.post;
			" category synths:".postln;
			value.do({ |name|
				"\\".post;
				name.postln;
			});
		});
		"GMDefs: uncategorized synths:".postln;
		noCategory.do({ |name|
			"\\".postln;
			name.postln;
		});
	},

	//------------------------//
	//    GLOBAL FUNCTIONS    //
	getDefaultPlayer: { |self|
		if(self[\defaultPlayer].isNil) {
			self[\defaultPlayer] = self.getPlayer;
		};
		self[\defaultPlayer]
	},

	uidCounter: 0,
	getUID: { |self|
		var uid = Date.getDate.format("%d%H%M%S");
		uid = uid ++ self[\uidCounter].asString;
		self[\uidCounter] = self[\uidCounter] + 1;
		uid = $$ ++ uid;
		uid = uid.asSymbol;
		uid
	},

	folder: nil,

	getScaleName: { |self, scale|
		self[\scaleNames][scale]
	},

	copyPaste: (),

	doCopy: { |self, symbol, data|
		self[\copyPaste][symbol] = data;
	},

	doPaste: { |self, symbol|
		var data = nil;
		if(self[\copyPaste][symbol].notNil) {
			data = self[\copyPaste][symbol].copy;
		};
		data
	},
);
~gmDefs.init;
)