(
SynthDef(\ColdPersonLoveClimateChange, { |out = 100, amp = 0.5, pan = 0|
    var sig, reverb;
    
    // Rich Additive Synthesis
    sig = Mix.fill(10, {
        |i|
        SinOsc.ar((i+1) * 100, 0, 0.1) * EnvGen.kr(Env.perc(0.01, 1), doneAction: 2)
    });
    
    // Highlight mid-high band
    sig = BPF.ar(sig, 2000, 0.5);
    
    // Apply reverb
    reverb = GVerb.ar(sig, roomsize: 80, revtime: 8, damping: 0.5);
    
    // Final amplitude adjustment
    sig = reverb * amp;
    
    // Stable panning
    sig = Pan2.ar(sig, pan);
    
    Out.ar(out, sig);
}).add;

Pdef(\ColdPersonLoveClimateChange,
    Pbind(
        \instrument, \ColdPersonLoveClimateChange,
        \dur, Pseq([0.5, 0.25, 0.75, 0.5], inf),
        \amp, 0.5,
        \pan, 0,
        \degree, Pseq((0..12).scramble, 20),
        \scale, Scale.serial,
        \octave, 4,
        \out, 100
    ).play
);
)