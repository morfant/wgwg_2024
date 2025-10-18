(
SynthDef(\CreativeSynth, {
    |out=0, amp=0.5, pan=0.0, freq=440|
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);
    sig = Mix.fill(10, { |i| SinOsc.ar(freq * (i + 1), 0, amp/10) });
    sig = sig * env;
    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

Pdef(\CreativeSynth,
    Pbind(
        \instrument, \CreativeSynth,
        \dur, Pseq([0.2, 0.3, 0.4, 0.5], 12),
        \freq, Pseq([60, 62, 63, 65, 67, 68, 70, 72, 74, 75, 77, 78].midicps, 4),
        \amp, Pseq([0.4, 0.5, 0.6], 16),
        \pan, Pseq([0.0, -0.5, 0.5], 16)
    )
).play;
)