(
SynthDef(\StormyEmotion, {
    |out=0|
    var trig, reset, demandUGens, env, sound, pan;
    
    // Trigger signal
    trig = Impulse.kr(5); // 5 times per second
    
    // Reset signal
    reset = Impulse.kr(0.2); // Reset every 5 seconds
    
    // Demand UGens for frequency and amplitude
    demandUGens = Dseq([Dshuf([200, 250, 300, 350, 400], inf), Dshuf([0.5, 0.6, 0.7, 0.8, 0.9], inf)], inf);
    
    // Generate sound using Demand
    sound = SinOsc.ar(Demand.ar(trig, reset, demandUGens), 0, 0.2);
    
    // Envelope for short, sharp sounds
    env = EnvGen.kr(Env.perc(0.01, 0.1), trig, doneAction: 2);
    
    // Apply envelope to sound
    sound = sound * env;
    
    // Random panning for chaotic stereo effect
    pan = Demand.ar(trig, reset, Dshuf([-1, 1], inf));
    sound = Pan2.ar(sound, pan);
    
    Out.ar(out, sound);
}).add;
)