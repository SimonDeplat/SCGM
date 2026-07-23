(
var idDict = (
	name: "Pulser",
	symbol: \gmPulser,
	category: \drone,
	type: \synth,
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
			pair: \rlpFreq,
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
			symbol: \rlpFreq,
			default: 200,
			min: 100,
			max: 16000,
			scale: \exp,
			text: "RLP Freq",
			polarity: \uni,
			pair: \amp,
			axis: \x,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 2,
			helperSubdivisions: 8,
			// DisplayFunc
			displayFunction: { |value|
				value = value.asInteger;
				value = value.asString ++ "hz";
				value
			},
		),

		(
			type: \continuous,
			symbol: \rq,
			default: 0.5,
			min: 0.1,
			max: 1.0,
			scale: \lin,
			text: "RQ",
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
			values: [8, 4, 2, 1, 0.5],
			text: "freq mul.",
			texts: ["x8", "x4", "x2", "-", "/2"],
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	],
);

SynthDef(\gmPulser, { |out = 0, freq = 110, amp = 0,
	rlpFreq = 40, freqMul = 1, spread = 1, rq = 0.5|
	var snd = RLPF.ar(
		Saw.ar(freq / 2 * freqMul * [spread.reciprocal, spread]),
		rlpFreq,
		rq
	);
	snd = snd * amp * 0.75;
	snd = Limiter.ar(snd);
	Out.ar(out, snd);
}).add;

idDict
)