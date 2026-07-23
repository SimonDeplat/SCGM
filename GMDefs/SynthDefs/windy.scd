(
var idDict = (
	name: "Windy",
	symbol: \gmWindy,
	category: \drone,
	type: \synth,
	emission: \continuous,
	group: \synth,
	tunable: false,
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
			pair: \bpFreq,
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
			symbol: \bpFreq,
			default: 100,
			min: 50,
			max: 20000,
			scale: \exp,
			text: "freq",
			polarity: \uni,
			pair: \amp,
			axis: \x,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 4,
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
	],
);

SynthDef(\gmWindy, { |out = 0, amp = 0, bpFreq = 100|
	var snd = BPF.ar(
		[WhiteNoise.ar, WhiteNoise.ar],
		bpFreq, 1.0
	);
	snd = snd * amp;
	Out.ar(out, snd);

}).add;

idDict
)