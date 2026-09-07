(
var idDict = (
	name: "High Enhancer",
	symbol: \gmHighEnhancer,
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
			default: 3000,
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

		(
			type: \continuous,
			symbol: \amount,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amount",
			modSteps: [0.01, 0.001],
			displayFunction: { |value|
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
		),

		(
			type: \continuous,
			symbol: \amp,
			default: 1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			modSteps: [0.01, 0.001],
			displayFunction: { |value|
				(value.ampdb.trunc(0.01).asString ++ " db")
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

SynthDef(\gmHighEnhancer, { |out = 0, in,
	freq = 3000, amount = 0, amp = 1|

	var snd = In.ar(in, 2);
	var effect = HPF.ar(snd, freq, amount);
	snd = snd + effect;
	snd = snd * amp;
	Out.ar(out, snd);
}).add;

idDict
)