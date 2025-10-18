(
SynthDef(\ClimateCrisisJoy, {
    |out=0, freq=440, amp=0.5, pan=0|
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, 0.4), doneAction: 2);
    sig = Mix.fill(10, { SinOsc.ar(freq * (1 + LFNoise1.kr(0.5).range(-0.1, 0.1)), 0, amp / 10) });
    sig = sig * env;
    sig = Pan2.ar(sig, pan);
    Out.ar(out, sig);
}).add;

Pdef(\ClimateCrisisJoy, Pbind(
    \instrument, \ClimateCrisisJoy,
    \dur, Pseq([0.2, 0.3, 0.4, 0.5], inf),
    \freq, Pxrand([60, 63, 67, 70, 72, 75, 78, 82].midicps, inf),
    \amp, 0.5,
    \pan, Pwhite(-0.5, 0.5, inf)
)).play;
)