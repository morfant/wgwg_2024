(
SynthDef(\ClimateCrisisNeolibSorrow, {
    |out=0, amp=0.5, freq=440, dur=0.5|
    var sig, env;
    env = Env.perc(0.01, dur, amp).ar(2);
    sig = Mix.fill(10, { SinOsc.ar(freq * (1 + LFNoise1.kr(0.5).range(0.01, 0.1)), 0, env) });
    sig = sig + (WhiteNoise.ar(0.3) * env);
    sig = sig * amp;
    Out.ar(out, Pan2.ar(sig, 0));
}).add;
)

// Pdef
(
Pdef(\ClimateCrisisNeolibSorrowPattern, Pbind(
    \instrument, \ClimateCrisisNeolibSorrow,
    \dur, Pseq(Array.fill(50, { rrand(0.2, 0.5) }), 20),
    \freq, Pseq(Array.fill(50, { Scale.minor.degrees.choose.midicps }), 20),
    \amp, 0.5012,
    \pan, Prand([-0.5, 0.5], inf)
))
)