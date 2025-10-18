(
SynthDef(\CatLoveClimateChange, { |out = 100, amp = 0.5, pan = 0|
    var sig, reverb;
    
    // Rich Additive Synthesis
    sig = Mix.fill(10, { |i|
        var freq = 200 + 100 * i;
        SinOsc.ar(freq, 0, amp / 10)
    });
    
    // Applying reverb
    reverb = GVerb.ar(sig, 80, 8, 0.5, 0.7, 15, 1, 0.7, 0.5);
    
    // Panning
    sig = Pan2.ar(reverb, pan);
    
    // Output to bus
    Out.ar(out, sig);
}).add;

Pdef(\CatLoveClimateChange, 
    Pbind(
        \instrument, \CatLoveClimateChange,
        \dur, Pseq([0.5, 0.75, 0.5, 0.25], 20),
        \freq, Pseq([
            440, 494, 523, 587,
            659, 698, 784, 880,
            987, 1047, 1175, 1319,
            1397, 1568, 1760, 1975,
            2093, 2349, 2637, 2794
        ], 1).mirror1,
        \amp, 0.5,
        \pan, 0
    ).play
);
)