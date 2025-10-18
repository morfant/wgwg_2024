(
SynthDef(\EmotionalStorm, {
    |out=0, freq=100, amp=0.5, dur=6|
    
    var trigger, env, sound, panner, demandFreq, demandDur;
    
    // Generate random triggers for Demand
    trigger = Dust.kr(30); 
    demandFreq = Demand.kr(trigger, 0, Dseq([100, 150, 200, 250, 300, 350, 400, 450, 500], inf));
    demandDur = Demand.kr(trigger, 0, Dseq([0.1, 0.2, 0.3, 0.4, 0.5], inf));

    // Envelope for sound shaping
    env = EnvGen.kr(Env.perc(0.01, 0.05), trigger);

    // Sound source
    sound = SinOsc.ar(demandFreq, 0, env * amp * 0.5);

    // Panning
    panner = Pan2.ar(sound, LFNoise1.kr(5).range(-1, 1));
    
    // Output
    Out.ar(out, panner);
}).add;
)