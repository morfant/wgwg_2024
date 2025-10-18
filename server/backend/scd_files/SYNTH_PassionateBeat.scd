(
SynthDef(\PassionateBeat, { |out=100, amp=0.5, pan=0.0, rev=0.5|
    var sig, env, revSig;
    // Rich Additive Synthesis
    sig = Mix.fill(10, { SinOsc.ar((50..150).choose + (0..10).rand, 0, 0.1) });
    env = EnvGen.kr(Env.perc(0.01, 2.5 + 0.5.rand), doneAction: 2);
    sig = sig * env * amp;
    
    // Reverberation
    revSig = FreeVerb.ar(sig, mix: rev, room: 0.85, damp: 0.5);
    
    // Panning
    sig = Pan2.ar(revSig, pan);
    
    // Output
    Out.ar(out, sig);
}).add;

Pdef(\PassionateBeat,
    Pbind(
        \instrument, \PassionateBeat,
        \dur, Pseq([2.5, 3.0], 25),
        \amp, Pwhite(0.3, 0.5, 50),
        \pan, Pwhite(-0.5, 0.5, 50),
        \rev, 0.5,
        \scale, Scale.minor,
        \degree, Pseq((0..7).choose, 25),
        \out, 100
    )
).play;
)