(
SynthDef(\ClimateChangeSeriousness, {
    arg out=0;
    var ampEnv, freqEnv, sound, panner;
    
    // Amplitude Envelope (20 seconds)
    ampEnv = EnvGen.kr(
        Env.asr(0.01, 1, 0.01, 1),
        timeScale: 20
    );
    
    // Frequency Envelope (20 seconds)
    freqEnv = EnvGen.kr(
        Env.perc(0.01, 0.99, 1),
        timeScale: 20
    );
    
    // Sound texture: Inflating Balloon
    sound = SinOsc.ar(
        freq: freqEnv * XLine.kr(100, 1000, 20),
        mul: ampEnv * 0.8
    );
    
    // Melody: Rock'n Roll (simple pattern)
    var melodyPattern = Pseq([60, 62, 64, 65, 67, 69, 71, 72], inf).asStream;
    var melodyFreq = Demand.kr(Impulse.kr(4), 0, Dseq(melodyPattern, inf)).midicps;
    var melodySound = Saw.ar(melodyFreq) * ampEnv * 0.2;
    
    // Combine sound textures
    sound = sound + melodySound;
    
    // Panning (stable)
    panner = Pan2.ar(sound, 0, 1);
    
    // Output with amplitude adjustment
    Out.ar(out, panner * 0.8);
}).add;
)