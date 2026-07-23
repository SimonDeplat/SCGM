(
var idDict = (
	name: "Reverb",
	symbol: \gmReverb,
	category: \spatialization,
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
			type: \continuous,
			symbol: \decay,
			default: 0.25,
			min: 0.05,
			max: 8,
			scale: \exp,
			text: "decayTime",
			modSteps: [0.1, 0.01]
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

SynthDef(\gmReverb, { |out = 0, in,
	amp = 1, decay = 1, dry = 1, wet = 0|

	var snd = In.ar(in, 2);
	var effect = snd;
	4.do({
		effect = AllpassC.ar(
			// Update max if needed
			effect,
			0.05,
			{ 0.05.rand }.dup,
			decay
		);
	});

	snd = snd * dry;
	effect = effect * wet;
	snd = snd + effect;

	snd = snd * amp;
	Out.ar(out, snd);
}).add;

idDict
)