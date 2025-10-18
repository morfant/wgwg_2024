(
SynthDef(\WorriedEmotionSound, {
    arg out=0, amp=0.1;
    var sig, env, freqs, trig;
    
    trig = Dust.kr(1);  // Random trigger for events
    freqs = [130, 196, 220, 261, 293, 329, 349, 391];  // Mid-low frequencies

    // Creating a sequence of short, sharp sounds
    sig = SinOsc.ar(
        Select.kr(Demand.kr(trig, 0, Dseq(freqs, inf))),  // Randomly select a frequency
        0,
        LFNoise1.kr(8) * 0.1 + 0.15  // Modulate the amplitude for a sharp effect
    );

    // Apply a random pan to create a confusing stereo image
    sig = Pan2.ar(sig, LFNoise2.kr(2));

    // Envelope to control the duration of the sound
    env = EnvGen.kr(Env.perc(0.01, 0.05), trig) * amp;

    Out.ar(out, sig * env);
}).add;
)