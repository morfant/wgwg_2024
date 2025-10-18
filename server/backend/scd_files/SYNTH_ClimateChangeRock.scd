(
SynthDef(\ClimateChangeRock, {
    |freq = 440, amp = 0.5, pan = 0|
    var env, sound, mod, modFreq, modIndex, pannedSound;

    env = EnvGen.kr(Env.perc(0.1, 20.0), doneAction: 2);
    
    modFreq = LFNoise1.kr(0.5).range(10, 30); // Modulation frequency
    modIndex = LFNoise1.kr(0.5).range(0.1, 5); // Modulation index
    mod = SinOsc.ar(modFreq) * modIndex;
    
    sound = SinOsc.ar(freq + mod, 0, amp * env).tanh; // Additive or waveshaping synthesis
    
    pannedSound = Pan2.ar(sound, pan);
    
    Out.ar(0, pannedSound);
}).add;
)