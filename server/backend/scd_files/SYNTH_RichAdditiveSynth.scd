(
SynthDef(\RichAdditiveSynth, {
    arg out=0, freq=440, amp=0.5, pan=0;
    var sig, env;
    var harmonics = Array.fill(10, { |i| SinOsc.ar(freq * (i+1), 0, 1/(i+1)) });
    sig = Mix.new(harmonics) * amp;
    env = EnvGen.kr(Env.perc(0.01, 1.99), doneAction: 2);
    sig = sig * env;
    sig = Pan2.ar(sig, pan, 0.5);
    Out.ar(out, sig);
}).add;

Pdef(\RichAdditiveSynthPattern, 
    Pbind(
        \instrument, \RichAdditiveSynth,
        \dur, Pseq([1.5, 2.0], inf),
        \freq, Pseq([60, 62, 63, 65, 67, 68, 70, 72, 74, 75].midicps, 8),
        \amp, 0.5,
        \pan, 0,
        \scale, Scale.minor,
        \degree, Pseq([0, 2, 3, 5, 7, 8, 10, 12, 14, 15], 8)
    )
).play;
)