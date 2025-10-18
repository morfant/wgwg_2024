(
SynthDef(\CozyHouseSynth, {
    |out=100, amp=0.5, pan=0.0|
    var sig, env, freqs;
    
    // Define frequencies for rich additive synthesis
    freqs = [200, 300, 400, 500, 600];
    
    // Generate signal using rich additive synthesis
    sig = Mix.fill(freqs.size, { |i|
        var freq = freqs[i];
        SinOsc.ar(freq, 0, amp / freqs.size)
    });
    
    // Apply a simple ADSR envelope
    env = EnvGen.kr(Env.perc(0.01, 1), doneAction: 2);
    
    // Apply reverberation
    sig = FreeVerb.ar(sig, mix: 0.8, room: 0.8, damp: 0.5);
    
    // Pan the signal
    sig = Pan2.ar(sig, pan, env * 0.5);
    
    // Output the signal
    Out.ar(out, sig);
}).add;
)

(
Pdef(\CozyHouseSynth, 
    Pbind(
        \instrument, \CozyHouseSynth,
        \dur, Pseq([0.25, 0.5, 0.75, 1], 10),
        \degree, Pseq((0..7), 5),
        \pan, 0.0,
        \amp, Pseq([0.4, 0.6, 0.8, 0.5, 0.7], 3),
        \scale, Scale.serial
    )
).play
)