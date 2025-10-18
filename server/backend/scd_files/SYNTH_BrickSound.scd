(
SynthDef(\BrickSound, {
    |out=100, amp=0.5, pan=0, revMix=0.5|
    var sig, env, reverb;
    env = EnvGen.kr(Env.perc(0.01, 2.0), doneAction: 2);
    sig = Mix(Array.fill(10, { SinOsc.ar(rrand(100, 2000), 0, 0.1) }));
    sig = sig * env * amp;
    sig = Balance2.ar(sig, sig, pan);
    reverb = FreeVerb2.ar(sig, sig, mix: revMix);
    Out.ar(out, reverb);
}).add;

Pdef(\BrickSound, Pbind(
    \instrument, \BrickSound,
    \dur, Pseq([2.5, 2.8, 3.0], 16),
    \amp, Pseq([0.4, 0.5, 0.6], 16),
    \pan, Pwhite(-0.5, 0.5, inf),
    \revMix, 0.5,
    \scale, Scale.minor,
    \degree, Pseq([Pseries(0, 1, 50), Pseries(7, -1, 50)], 1)
)).play;
)