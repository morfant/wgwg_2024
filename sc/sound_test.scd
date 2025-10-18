~list = [ 0.3, 0.5, 0.3, 0.3, 0.3, 0.5, 0.3, 0.3, 0.5, 0.3, 0.3, 0.3, 0.1, 0.1, 0.1, 0.5, 0.5, 0.5, 0.1, 0.1, 0.5, 0.5, 0.5];

(
var idx = 1;
a = Pbind(
    \instrument, "morse_"++idx,
    \freq, Pseq(~morse_harmonic[idx], inf),
    \detune, 0.0,
    \tempo, 1.0,
	\amp, 0.2,
	\dur, Pseq(~list, inf),
).play
)


(
var idx = 2;
Pbind(
			\instrument, "morse_"++idx,
			// \midinote, 68,
			\freq, Pseq(~morse_harmonic[idx], inf),
			\detune, 0.0,
			\tempo, 1.0,
	        \amp, 0.05,
			\dur, Pseq(~list, inf),
	).play
)


(
var idx = 3;
a = Pbind(
			\instrument, "morse_"++idx,
			// \midinote, 68,
			\freq, Pseq(~morse_harmonic[idx], inf),
			\detune, 0.0,
			\tempo, 1.0,
            \amp, 0.1,
			\dur, Pseq(~list, inf),
	).play
)


(
var idx = 4;
Pbind(
			\instrument, "morse_"++idx,
			// \midinote, 68,
			\freq, Pseq(~morse_harmonic[idx], inf),
			\detune, 0.0,
			\tempo, 1.0,
	        \amp, 0.1,
			\dur, Pseq(~list, inf),
	).play
)


(
var idx = 5;
Pbind(
			\instrument, "morse_"++idx,
			// \midinote, 68,
			\freq, Pseq(~morse_harmonic[idx], inf),
			\detune, 0.0,
			\tempo, 1.0,
	        \amp, 0.2,
			\dur, Pseq(~list, inf),
	).play
)

