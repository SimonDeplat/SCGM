(
var idDict = (
	name: "S Dispatch",
	symbol: \gmSDispatch,
	category: \dispatch,
	type: \dispatch,
	emission: \continuous,
	tunable: false,
	dependencies: nil,

	params: [

		(
			type: \in,
			symbol: \in,
			numChannels: 2,
			text: "in",
		),

		(
			type: \out,
			symbol: \dispatchOut,
			numChannels: 2,
			text: "dispatch",
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmSDispatch, { |in, dispatchOut = 0, out = 0|
	var snd = In.ar(in, 2);
	Out.ar(out, snd);
	Out.ar(dispatchOut, snd);
}).add;

idDict
)