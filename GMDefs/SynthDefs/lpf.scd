(
var idDict = (
	name: "LPF",
	symbol: \gmLPF,
	category: \equalisation,
	type: \effect,
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
			type: \continuous,
			symbol: \freq,
			default: 5000,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "freq",
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmLPF, { |out = 0, in, freq = 5000|
	var snd = In.ar(in, 2);
	snd = LPF.ar(snd, freq);
	Out.ar(out, snd);
}).add;

idDict
)