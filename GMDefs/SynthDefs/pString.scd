(
var idDict = (
	name: "PString",
	symbol: \gmPString,
	category: \synth,
	type: \string,
	emission: \discrete,
	group: \synth,
	tunable: true,
	dependencies: nil,

	params: [

		(
			type: \env,
			symbol: \env,
			maxSize: 9,
			default: Env(
				[0, 0.9, 0.25, 0],
				[0.001, 0.25, 1],
				[0, -4, 0]
			),
			min: 0,
			max: 1,
			text: "env",
			timeScale: 2.0,
		),

		(
			type: \continuous,
			symbol: \amp,
			default: 0.8,
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
			symbol: \vibratoRate,
			default: 1,
			min: 8.reciprocal,
			max: 8,
			scale: \exp,
			text: "vibRate",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \vibratoAmount,
			default: 0,
			min: 0,
			max: 1,
			scale: \exp,
			text: "vibAmount",
			polarity: \uni,
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
			type: \continuous,
			symbol: \vibratoAtk,
			default: 1,
			min: 0.05,
			max: 4,
			scale: \exp,
			text: "vibAtk",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \cutoff,
			default: 300,
			min: 55,
			max: 14080,
			scale: \exp,
			text: "cutoff",
			polarity: \uni,
			// DisplayFunc
			displayFunction: { |value|
				if(value == 0) { value = "";
				} {
					value = value.trunc(0.01);
					value = value.asString ++ "hz";
				};
			},
		),

		(
			type: \continuous,
			symbol: \rq,
			default: 1,
			min: 0.1,
			max: 1,
			scale: \exp,
			text: "rq",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \character,
			default: 0.0005,
			min: 0.0005,
			max: 1,
			scale: \exp,
			text: "character",
			polarity: \uni,
		),

		(
			type: \continuous,
			symbol: \bridgePos,
			default: 1,
			min: 8.reciprocal,
			max: 8,
			scale: \exp,
			text: "bridgePos",
			polarity: \uni,
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
			default: 0.5,
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
	]
);

SynthDef(\gmPString, { |out = 0, amp = 1,
	freq = 110, spread = 1, freqMul = 1,
	vibratoRate = 3, vibratoAmount = 0.001, vibratoAtk = 1,
	cutoff = 300, rq = 1,
	character = 0.0015, bridgePos = 0|

	var snd, env, envGen;
	var vibrato, nHarms;

	env = Env.newClear(9);
	envGen = EnvGen.kr(
		\env.kr(env.asArray),
		doneAction: Done.freeSelf
	);

	nHarms = 9;

	freq = freq * freqMul * [spread.reciprocal, spread];
	vibrato = SinOsc.ar(vibratoRate, mul: vibratoAmount);
	vibrato = vibrato * EnvGen.ar(Env([0, 1], [vibratoAtk], [4]));
	vibrato = vibrato + 1;
	freq = freq * vibrato;

	snd = Silent.ar(2);

	nHarms.do({ |n|
		var detuner = SinOsc.ar(
			3.rand,
			mul: character.rand,
			add: 1
		);
		snd = snd + SinOsc.ar(
			freq: freq * detuner * (n + 1),
			phase: pi * sin(n * pi / ((bridgePos + 2) * 2)).abs,
			mul: ((1 / (n + 1).pow(2))
				* sin(
					(n + 1) * (pi) / (bridgePos + 2)
				).abs
			)
		);
	});

	// Quick cutoff decrease to give
	// some initial brightness to the sound
	snd = RLPF.ar(
		snd,
		XLine.kr(
			min(
				cutoff * 2,
				20000
			),
			cutoff,
			0.1
		),
		rq
	);

	snd = snd * envGen;
	snd = snd * amp;

	Out.ar(out, snd);
}).add;

idDict
)