(
var idDict = (
	name: "Sin2LFO",
	symbol: \gmSin2LFO,
	category: \misc,
	type: \effect,
	emission: \continuous,
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
				(value.ampdb.trunc(0.01).asString ++ " db")
			},
		),

		(
			type: \tempo,
			symbol: \tempo
		),

		(
			type: \tempoRate,
			symbol: \tempoRate,
			default: 1,
			text: "rate",
		),

		(
			type: \continuous,
			symbol: \power,
			default: 1,
			min: 16.reciprocal,
			max: 16,
			scale: \exp,
			text: "power",
		),

		(
			type: \continuous,
			symbol: \phase,
			default: 0,
			min: 0,
			max: 2pi,
			scale: \lin,
			text: "phase",
			// DisplayFunc
			displayFunction: { |value|
				value = value.raddeg;
				value = value.round;
				value = value.asInteger;
				value = value.asString;
				value = value ++ "°";
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

SynthDef(\gmSin2LFO, { |out = 0, in, amount = 0,
	tempo = 60, tempoRate = 1, phase = 0, power = 1|

	var snd, lfo;
	snd = In.ar(in, 2);
	lfo = SinOsc.kr(
		(tempo * tempoRate).reciprocal / 2,
		phase
	);
	lfo = lfo.abs;
	lfo = lfo.pow(power);
	lfo = lfo * amount;
	lfo = lfo + (1 - amount);
	snd = snd * lfo;
	Out.ar(out, snd);

}).add;

idDict
)