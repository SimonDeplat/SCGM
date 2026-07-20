(
var idDict = (
	name: "RLPF",
	symbol: \gmRLPF,
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

		// MAX: 2.sqrt
		(
			type: \continuous,
			symbol: \rq,
			default: 1,
			min: 0.05,
			max: 1.414,
			scale: \exp,
			text: "rq",
			modSteps: [0.01, 0.001],
		),

		(
			type: \continuous,
			symbol: \dry,
			default: 1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "dry",
			modSteps: [0.01, 0.001]
		),

		(
			type: \continuous,
			symbol: \wet,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "wet",
			modSteps: [0.01, 0.001]
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmRLPF, { |out = 0, in,
	freq = 5000, rq = 1, dry = 1, wet = 0|
	var snd, effect;
	snd = In.ar(in, 2);
	effect = RLPF.ar(snd, freq, rq);
	snd = snd * dry;
	effect = effect * wet;
	snd = snd + effect;
	Out.ar(out, snd);
}).add;

idDict
)