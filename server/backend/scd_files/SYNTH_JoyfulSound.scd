(
SynthDef(\JoyfulSound, {
    arg out = 0, amp = 0.5, dur = 60;
    var freq, env, sound, lfo, filterFreq, sig;

    // Frequency pattern (mimicking Haydn's feeling)
    freq = Demand.kr(Dust.kr(1), 0, Dseq([220, 330, 440, 550, 660, 770, 880], inf));

    // Envelope for each note
    env = EnvGen.kr(Env.perc(0.1, 0.9), doneAction: 2);

    // Low-frequency oscillator for vibrato effect
    lfo = SinOsc.kr(5, 0, 0.02, 1);

    // Main sound synthesis
    sound = SinOsc.ar(freq * lfo) * env;

    // Filter frequency pattern (emphasizing mid-low and high frequencies)
    filterFreq = Demand.kr(Dust.kr(1), 0, Dseq([200, 400, 600, 800, 1000, 1200, 1400], inf));

    // Apply a filter
    sig = RLPF.ar(sound, filterFreq, 0.2);

    // Panning for stable stereo image
    sig = Pan2.ar(sig, 0);

    // Output with amplitude control
    Out.ar(out, sig * amp);
}).add;
)