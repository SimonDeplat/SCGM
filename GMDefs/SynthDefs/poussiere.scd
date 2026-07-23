(
var idDict = (
	name: "Poussiere",
	symbol: \gmPoussiere,
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
			axis: \y,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 3,
			helperSubdivisions: 4,
			displayFuncton: { |value|
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
		),

		(
			type: \continuous,
			symbol: \density,
			default: 0.5,
			min: 0.5,
			max: 10000,
			scale: \exp,
			text: "density",
			polarity: \uni,
			pair: \amp,
			axis: \x,
			// Helpers
			displayHelpers: true,
			helpersStyle: \dot,
			helpersNumber: 2,
			helperSubdivisions: 8,
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	],
);

SynthDef(\gmPoussiere, { |out = 0, freq = 110, amp = 0, density = 0.5|
	var snd = Dust2.ar(density);
	snd = snd * amp;
	snd = snd!2;
	Out.ar(out, snd);
}).add;

idDict
)