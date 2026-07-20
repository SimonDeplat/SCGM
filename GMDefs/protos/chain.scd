(
init: { |self|
	self
},

setSynths: { |self, synthNames|
	self[\synths] = List(0);
	self[\synthByNames] = ();

	// Create synths
	synthNames.do({ |synthName, index|
		var synth;
		synth = ~gmDefs.getSynth(synthName);
		self[\synths].add(synth);
		self[\synthByNames][synthName.asSymbol] = synth;
	});

	self[\source] = self[\synths][0];

	// Plug 'em in
	fork {
		s.sync;
		(self[\synths].size - 1).do({ |index|
			self[\synths][index].setParam(
				\out,
				self[\synths][index + 1][\busses][\in]
			);
		});
	};

	self
},

getSynth: { |self, synthName|
	self[\synthByNames][synthName.asSymbol]
},

setPlayer: { |self, player|
	self[\player] = player;

	self[\synths].do({ |synth|
		synth.setPlayer(player);
	});

	self
},

bindPlayer: { |self, player|
	self[\player] = player;

	self[\synths].do({ |synth|
		synth.bindPlayer(player);
	});

	self
},

setOut: { |self, bus|
	self[\synths].last.setParam(\out, bus);
	self
},
)