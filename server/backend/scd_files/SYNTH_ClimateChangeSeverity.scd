SynthDef(\ClimateChangeSeverity, {
    |amp = -6, envDur = 20.0|
    var sig, env, freqs, melody1, melody2, melody3, trigSeq, pan;

    // Envelope
    env = EnvGen.kr(Env.perc(0.01, envDur), doneAction: 2);

    // Frequencies for Gothic classic melody
    freqs = [220, 330, 440, 550, 660, 770, 880];

    // Trigger sequences
    trigSeq = Impulse.kr(1/0.25);

    // Melody lines
    melody1 = Demand.kr(trigSeq, 0, Dseq(freqs, 7));
    melody2 = Demand.kr(trigSeq, 0, Dseq(freqs.scramble, 7));
    melody3 = Demand.kr(trigSeq, 0, Dseq(freqs.reverse, 7));

    // Sound synthesis using Additive
    sig = SinOsc.ar([melody1, melody2, melody3], 0, [0.3, 0.3, 0.3]);

    // Mixing and panning
    pan = Pan2.ar(Mix(sig) * env * amp.dbamp, 0);

    // Output
    Out.ar(0, pan);
}).add;