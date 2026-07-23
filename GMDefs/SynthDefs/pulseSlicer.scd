(
var idDict = (
	name: "Pulse Slicer",
	symbol: \gmPulseSlicer,
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
			text: "in",
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
			// DisplayFunc
			displayFunction: { |value|
				value = value * 100;
				value = value.round(1);
				value = value.asInteger;
				value = value.asString;
				value = value ++ "%";
				value
			},
		),

		(
			type: \tempoRate,
			symbol: \tempoRate,
			text: "rate",
		),

		(
			type: \continuous,
			symbol: \duty,
			default: 0.5,
			min: 0,
			max: 1,
			scale: \lin,
			text: "duty",
		),

		(
			type: \continuous,
			symbol: \lagTime,
			default: 0.05,
			min: 0.005,
			max: 1,
			scale: \exp,
			text: "lag",
		),

		(
			type: \out,
			symbol: \out,
			numChannels: 2,
			text: "out",
		),
	]
);

SynthDef(\gmPulseSlicer, { |out = 0, in, amount = 0,
	tempo = 60, tempoRate = 1,
	lagTime = 0.005, duty = 0.5|

	var snd, lfo;
	snd = In.ar(in, 2);
	lfo = LFPulse.kr(
		tempoRate,
		0,
		duty
	);
	lfo = Lag.kr(lfo, lagTime);
	lfo = lfo.abs;
	lfo = lfo * amount;
	lfo = lfo + (1 - amount);
	snd = snd * lfo;
	Out.ar(out, snd);

}).add;

idDict
)