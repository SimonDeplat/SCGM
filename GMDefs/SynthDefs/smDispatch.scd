(
var idDict = (
	name: "SM Dispatch",
	symbol: \gmSMDispatch,
	category: \dispatch,
	type: \dispatch,
	emission: \continuous,
	group: \filter,
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
			numChannels: 1,
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

SynthDef(\gmSMDispatch, { |in, dispatchOut = 0, out = 0|
	var snd = In.ar(in, 2);
	var dispatchSnd = Mix.ar([snd[0], snd[1]]);
	Out.ar(out, snd);
	Out.ar(dispatchOut, dispatchSnd);
}).add;

idDict
)