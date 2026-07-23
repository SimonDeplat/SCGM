(
var idDict = (
	name: "Sine",
	symbol: \gmSine,
	category: \drone,
	type: \drone,
	emission: \continuous,
	group: \synth,
	tunable: true,
	dependencies: nil,

	params: [

		(
			type: \continuous,
			symbol: \amp,
			default: 0,
			min: 0,
			max: 1,
			scale: \lin,
			text: "amp",
			polarity: \uni,
			pair: \blipHarm,
			axis: \y,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 4,
			displayFunction: { |value|
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
		),

		(
			type: \continuous,
			symbol: \spread,
			default: 1,
			min: 1,
			max: 2,
			scale: 8,
			text: "spread",
			polarity: \uni,
			// Helpers
			displayHelpers: true,
			multiSliderDisplayHelpers: true,
			helpersRatio: 0.05,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 1,
			// Mod Steps
			modStep: 1.01,
			modStepOperator: \mul,
			modStep2: 1.001,
			modStep2Operator: \mul,
			// DisplayFunc
			displayFunction: { |value|
				value = value - 1;
				value = value * 100;
				if(value < 10) {
					value = value.trunc(0.01);
				} {
					value = value.asInteger;
				};
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \discrete,
			symbol: \freqMul,
			default: 1,
			values: [8, 4, 2, 1, 0.5, 0.25, 0.125],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2", "/4", "/8"],
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	],
);

SynthDef(\gmSine, {
	|out = 0, freq = 440, amp = 0, spread = 1, freqMul = 1|
	var snd = SinOsc.ar(
		freq * freqMul * [spread.reciprocal, spread],
	) * amp * 0.75;
	Out.ar(out, snd);
}).add;

idDict
)