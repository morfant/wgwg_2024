(
SynthDef(\ClimateChangeJazz, {
    arg out=0, amp=0.5, pan=0;
    var env, sound, freq, trig, demandEnv, melody, soundTexture;

    // Envelope
    env = EnvGen.kr(Env.perc(0.01, 20), doneAction: 2);

    // Frequency pattern for melody
    trig = Impulse.kr(5);
    freq = Demand.kr(trig, 0, Dseq([60, 62, 64, 65, 67, 69, 71, 72] * 0.5.midicps, 8));

    // Sound texture - a series of glissando effects like a balloon inflating
    demandEnv = EnvGen.kr(Env.perc(0.01, 20), doneAction: 2);
    soundTexture = SinOsc.ar(Demand.kr(trig, 0, Dseq([440, 660, 880, 1100, 1320, 1540], 6)), 0, demandEnv);

    // Melody
    melody = SinOsc.ar(freq, 0, 0.1);

    // Combine sound texture and melody
    sound = soundTexture + melody;

    // Output with panning
    Out.ar(out, Pan2.ar(sound * env * amp, pan));
}).add;
)