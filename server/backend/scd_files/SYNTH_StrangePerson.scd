(
SynthDef(\StrangePerson, {
    |outBus = 0|
    var freq1, freq2, ampEnv, sig, pan, amp, dur;
    
    // Frequency Sequences
    freq1 = Demand.kr(Dust.kr(10), 0, Dseq([60, 62, 63, 65, 67, 68, 70, 72, 73, 75, 77, 78, 80, 82, 83, 85, 87, 88, 90, 92, 93, 95, 97, 98, 100, 102, 103, 105, 107, 108, 110, 112, 113, 115, 117, 118, 120, 122, 123, 125, 127, 128, 130, 132, 133, 135, 137, 138, 140], 4));
    freq2 = Demand.kr(Dust.kr(10), 0, Dseq([60, 62, 63, 65, 67, 68, 70, 72, 73, 75, 77, 78, 80, 82, 83, 85, 87, 88, 90, 92, 93, 95, 97, 98, 100, 102, 103, 105, 107, 108, 110, 112, 113, 115, 117, 118, 120, 122, 123, 125, 127, 128, 130, 132, 133, 135, 137, 138, 140], 4));
    
    // Amplitude Envelope
    ampEnv = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);
    
    // Durations
    dur = Demand.kr(Dust.kr(10), 0, Dseq([0.2, 0.3, 0.4, 0.5], 4));
    
    // Amplitude
    amp = 0.501187; // -6dB
    
    // Synthesis
    sig = Mix([SinOsc.ar(freq1), SinOsc.ar(freq2)]) * ampEnv * amp;
    
    // Panning
    pan = 0;
    sig = Pan2.ar(sig, pan);
    
    // Output
    Out.ar(outBus, sig);
}).add;
)