(
SynthDef(\CapitalismGoodSide, {
    var trig, freq, amp, env, sig, pan, mel1, mel2, mel3, mel4, mel5, dseq1, dseq2, dseq3, dseq4, dseq5;

    trig = Impulse.kr(5); // Trigger for the Demand UGens

    dseq1 = Dseq([60, 62, 64, 65, 67, 69, 71, 72], inf); // Melody sequence 1
    dseq2 = Dseq([67, 69, 71, 72, 74, 76, 77, 79], inf); // Melody sequence 2
    dseq3 = Dseq([72, 74, 76, 77, 79, 81, 83, 84], inf); // Melody sequence 3
    dseq4 = Dseq([77, 79, 81, 83, 84, 86, 88, 89], inf); // Melody sequence 4
    dseq5 = Dseq([83, 84, 86, 88, 89, 91, 93, 95], inf); // Melody sequence 5

    freq = [
        Demand.ar(trig, 0, dseq1).midicps,
        Demand.ar(trig, 0, dseq2).midicps,
        Demand.ar(trig, 0, dseq3).midicps,
        Demand.ar(trig, 0, dseq4).midicps,
        Demand.ar(trig, 0, dseq5).midicps
    ];

    amp = LFNoise0.kr(0.5).range(0.3, 0.6); // Amplitude modulation

    env = EnvGen.kr(Env.perc(0.01, 0.5), trig, doneAction: 2); // Envelope

    mel1 = SinOsc.ar(freq[0], 0, amp) * env;
    mel2 = SinOsc.ar(freq[1], 0, amp) * env;
    mel3 = SinOsc.ar(freq[2], 0, amp) * env;
    mel4 = SinOsc.ar(freq[3], 0, amp) * env;
    mel5 = SinOsc.ar(freq[4], 0, amp) * env;

    sig = mel1 + mel2 + mel3 + mel4 + mel5;

    pan = Pan2.ar(sig, 0, 0.6); // Panning

    Out.ar(0, pan);
}).add;
)