(
SynthDef(\GentleWindSoundscape, {
    var env, freqs, amps, panPos, sig;
    
    // Envelope
    env = EnvGen.kr(Env.new, doneAction: 2);
    
    // Frequencies and amplitudes for 5 melody lines
    freqs = Array.fill(5, { Demand.kr(Impulse.kr(1.0/4), 0, Dseq([60, 63, 67, 70, 74, 77, 81].midicps, 7)) });
    amps = Array.fill(5, { Demand.kr(Impulse.kr(1.0/4), 0, Dseq([0.1, 0.2, 0.15, 0.25, 0.3], 5)) * env });
    
    // Panning positions for 5 melody lines
    panPos = Array.fill(5, { LFNoise1.kr(0.5) });
    
    // Rich Additive Synthesis
    sig = Mix.fill(5, { |i| Pan2.ar(SinOsc.ar(freqs[i], 0, amps[i]), panPos[i]) });
    
    // Output
    Out.ar(0, sig * -6.dbamp);
}).add;
)