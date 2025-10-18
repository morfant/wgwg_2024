(
SynthDef(\RainyMorningCalm, {
	arg amp = 0.5, dur = 6, freq = 440, panPos = 0;
	var env, osc, pan, reverb, demandSeq;
	env = EnvGen.kr(Env.perc(0.01, 1), doneAction: 2);
	demandSeq = Demand.kr(Dseq([0.2, 0.3, 0.4, 0.5], inf), 0);
	osc = SinOsc.ar(freq, 0, env) + Saw.ar(freq * 0.5, 0.3) + Pulse.ar(freq * 2, 0.1);
	pan = Pan2.ar(osc, LFNoise2.kr(demandSeq));
	reverb = FreeVerb.ar(pan, mix: 0.4, room: 0.5, damp: 0.3);
	Out.ar(0, reverb * amp * -6.dbamp);
}).add;
)