(
SynthDef(\LoveAggressive, {
    arg out=0;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);
    sig = Mix.fill(5, {
        var freq = ExpRand(20, 2000);
        var amp = LFNoise1.kr(ExpRand(0.1, 1)).range(0.5, 1);
        var pan = LFNoise1.kr(ExpRand(0.1, 1)).range(-1, 1);
        Resonz.ar(BrownNoise.ar(amp), freq, 0.1) * env
    });
    sig = sig.tanh;
    sig = sig * Line.kr(1, 0, Rand(5.0, 8.0), doneAction: 2);
    sig = sig.dbamp(-6);
    Out.ar(out, sig);
}).add;
)