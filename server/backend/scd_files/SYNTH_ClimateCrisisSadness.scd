(
SynthDef(\ClimateCrisisSadness, {
    var freqs1, freqs2, env1, env2, sig1, sig2, amp = 0.5;
    
    // Define frequency patterns for two melody lines
    freqs1 = Demand.kr(Impulse.kr(5), 0, Dseq([60, 62, 63, 65, 67, 68, 70], 50).midicps);
    freqs2 = Demand.kr(Impulse.kr(4), 0, Dseq([72, 74, 75, 77, 79, 80, 82], 50).midicps);
    
    // Define envelopes
    env1 = EnvGen.kr(Env.perc(0.1, 0.4), doneAction: 2);
    env2 = EnvGen.kr(Env.perc(0.1, 0.4), doneAction: 2);
    
    // Sine wave oscillators
    sig1 = SinOsc.ar(freqs1) * env1;
    sig2 = SinOsc.ar(freqs2) * env2;
    
    // Additive synthesis with rich harmonics
    sig1 = sig1 + (SinOsc.ar(freqs1 * 2) * 0.5 * env1) + (SinOsc.ar(freqs1 * 3) * 0.25 * env1);
    sig2 = sig2 + (SinOsc.ar(freqs2 * 2) * 0.5 * env2) + (SinOsc.ar(freqs2 * 3) * 0.25 * env2);
    
    // Combine both signals
    sig1 = sig1 + sig2;
    
    // Apply amplitude and pan
    sig1 = Pan2.ar(sig1, 0, amp * 0.5);
    
    Out.ar(0, sig1);
}).add;

Pdef(\ClimateCrisisSadness, Pbind(
    \instrument, \ClimateCrisisSadness,
    \dur, 0.25,
    \legato, 1,
    \amp, 0.5,
    \scale, Scale.minor,
    \degree, Pseq([0, 2, 3, 5, 7, 8, 10], 20)
));
)