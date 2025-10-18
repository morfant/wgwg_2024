(
SynthDef(\BreezyWeather, {
	arg out=0, amp=0.5, freq=440, dur=1.5;
	var env, sig;
	env = EnvGen.kr(Env.perc(0.01, dur), doneAction:2);
	sig = SinOsc.ar(freq, 0, amp) * env;
	sig = sig * EnvGen.kr(Env([0, 1, 1, 0], [0.1, dur-0.2, 0.1], 'lin'), doneAction:2);
	sig = (sig * 0.5).dup;
	Out.ar(out, sig);
}).add;
)