(
SynthDef(\WorrisomeEmotion, {
    arg out=0;
    var sig, freq, env, pan;
    
    // Frequency sequence with some randomness
    freq = Demand.kr(Impulse.kr(8), 0, Dseq([Dshuf([200, 250, 300, 350, 400, 450], inf)], inf));
    
    // Envelope for a sharp attack and short decay
    env = EnvGen.kr(Env.perc(0.01, 0.2), doneAction: 2);
    
    // Generate sound using SineOsc for a smooth tone
    sig = SinOsc.ar(freq) * env * 0.3;
    
    // Adding some randomness to the pan position
    pan = LFSaw.kr(1).range(-1, 1);
    
    // Panning the signal
    sig = Pan2.ar(sig, pan);
    
    // Output the signal
    Out.ar(out, sig);
}).add;
)