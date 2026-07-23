(
var idDict = (
	name: "Echo",
	symbol: \gmEcho,
	category: \misc,
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
			text: "In",
		),

		(
			type: \continuous,
			symbol: \amp,
			default: 1,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: false,
			helpersStyle: \line,
			centerHelpers: false,
			helpersRatio: 0.333,
			helpersNumber: 3,
			helperSubdivisions: 4,
			// Mod Steps
			modStep: 0.01,
			modStepOperator: \add,
			modStep2: 1.1,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
		),

		(
			type: \continuous,
			symbol: \amount,
			default: 0.7,
			min: 0.01,
			max: 0.999,
			scale: \log,
			text: "amount",
			modSteps: [0.1, 0.01],
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.trunc(0.1);
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \tempoDur,
			symbol: \delay,
			text: "delay.",
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

SynthDef(\gmEcho, { |out = 0, in, amp = 1,
	dry = 1, wet = 0, amount = 0.5, delay = 1|

	var snd, effect, local;
	snd = In.ar(in, 2);
	local = LocalIn.ar(2);
	effect = Mix.ar([snd, local]);
	// Update max if needed
	effect = DelayC.ar(
		effect,
		10,
		(delay - ControlRate.ir.reciprocal)
		.clip((SampleDur.ir * 4), 10)
	);
	LocalOut.ar(effect  * amount);
	snd = snd * dry;
	effect = effect * wet;
	snd = snd + effect;
	snd = snd * amp;
	snd = LeakDC.ar(snd);
	Out.ar(out, snd);
}).add;

idDict
)