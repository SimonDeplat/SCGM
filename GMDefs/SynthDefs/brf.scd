(
var idDict = (
	name: "BRF",
	symbol: \gmBRF,
	category: \equalisation,
	type: \effect,
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
			type: \continuous,
			symbol: \freq,
			default: 5000,
			min: 20,
			max: 16000,
			scale: \exp,
			text: "freq",
			modSteps: [0.01, 0.001],
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		// VALUES > 1.1 cause problems
		// with high frequencies
		(
			type: \continuous,
			symbol: \rq,
			default: 1,
			min: 0.1,
			max: 1,
			scale: \exp,
			text: "rq",
			modSteps: [0.01, 0.001],
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmBRF, { |out = 0, in, freq = 5000, rq = 1|
	var snd = In.ar(in, 2);
	snd = BRF.ar(snd, freq, rq);
	Out.ar(out, snd);
}).add;

idDict
)