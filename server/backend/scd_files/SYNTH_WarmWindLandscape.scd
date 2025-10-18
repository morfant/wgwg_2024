(
SynthDef(\WarmWindLandscape, {
    |out=0, amp=0.5|
    var env, seq1, seq2, noteDur, freqs, trig, pan, sig;
    
    // Envelope
    env = Env.new([0, 1, 0.8, 0], [0.01, 0.18, 0.01], 'sin');
    
    // Trigger
    trig = Impulse.ar(10);
    
    // Note Duration
    noteDur = Dseq(Dwhite(0.2, 0.5, 50), inf);
    
    // Frequency sequence for two melody lines
    freqs = [
        Dseq(Dshuf([220, 247, 262, 294, 330, 349, 392, 440], 50), inf),
        Dseq(Dshuf([220, 233, 261, 277, 311, 329, 369, 415], 50), inf)
    ];
    
    // Melody sequences
    seq1 = Demand.ar(trig, 0, freqs[0]);
    seq2 = Demand.ar(trig, 0, freqs[1]);
    
    // Panning
    pan = Line.kr(-0.5, 0.5, 20);
    
    // Synthesized sound
    sig = Mix([SinOsc.ar(seq1) * EnvGen.kr(env, trig), SinOsc.ar(seq2) * EnvGen.kr(env, trig)]);
    sig = Pan2.ar(sig, pan) * amp;
    
    Out.ar(out, sig);
}).add;
)