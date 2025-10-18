(
SynthDef(\ClimateChangeUrgency, {
    |out=0, amp=0.5|
    var trig, freq, env, sig, panning;
    
    trig = Impulse.kr(8);  // Trigger for Demand UGens
    
    // Frequency demand
    freq = Demand.kr(trig, 0, Dseq([60, 62, 64, 67, 69, 72, 74, 76], inf).midicps);
    
    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 0.2), trig, doneAction: 2);
    
    // Sound synthesis using additive synthesis
    sig = SinOsc.ar(freq, 0, env) + SinOsc.ar(freq * 1.5, 0, env * 0.5) + SinOsc.ar(freq * 2, 0, env * 0.3);
    
    // Apply amplitude
    sig = sig * amp;
    
    // Panning
    panning = Pan2.ar(sig, 0);
    
    // Output
    Out.ar(out, panning);
}).add;
)