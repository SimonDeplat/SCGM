(
var idDict = (
	name: "2LHPF",
	symbol: \gm2LHPF,
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
			symbol: \hpFreq,
			default: 20,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "low cut",
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
			symbol: \lpFreq,
			default: 20000,
			min: 20,
			max: 20000,
			scale: \exp,
			text: "high cut",
			modSteps: [0.01, 0.001],
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

SynthDef(\gm2LHPF, { |out = 0, in, lpFreq = 20000, hpFreq = 20|
	var snd = In.ar(in, 2);
	2.do({ snd = LPF.ar(snd, lpFreq); });
	2.do({ snd = HPF.ar(snd, hpFreq); });
	Out.ar(out, snd);
}).add;

idDict
)