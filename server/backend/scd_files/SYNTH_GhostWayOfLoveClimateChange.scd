(
SynthDef(\GhostWayOfLoveClimateChange, {
    arg out=100, amp=0.5, pan=0, freq=440;
    var sig, reverb;
    
    // Using Rich Additive Synthesis
    sig = Mix.fill(8, { SinOsc.ar(freq * (1 + Rand(0.1, 0.5)), 0, 0.125) });
    sig = sig * amp.dbamp; // Final amplitude around -6dB
    sig = Pan2.ar(sig, pan);
    
    // Adding reverberation
    reverb = FreeVerb.ar(sig, mix: 0.8, room: 0.8, damp: 0.5);
    
    Out.ar(out, reverb);
}).add;

Pdef(\GhostWayOfLoveClimateChange,
    Pbind(
        \instrument, \GhostWayOfLoveClimateChange,
        \dur, Pseq([0.5, 0.75, 1, 1.25], 20),
        \freq, Pseq([440, 550, 660, 770].scramble, 20),
        \amp, 0.5,
        \pan, 0,
        \out, 100
    )
).play;
)