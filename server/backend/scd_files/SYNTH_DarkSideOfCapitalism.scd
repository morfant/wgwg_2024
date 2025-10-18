(
SynthDef(\DarkSideOfCapitalism, {
    var env, freqs, amps, pan, sig;
    
    // Define the envelope
    env = EnvGen.kr(Env.new([0, 1, 0.3, 0], [0.01, 19.0, 0.99], 'lin'), doneAction: 2);
    
    // Define frequencies and amplitudes for the additive synthesis
    freqs = [200, 400, 800];
    amps = [0.5, 0.3, 0.2];
    
    // Panning
    pan = Line.kr(-0.5, 0.5, 20.0, doneAction: 2);
    
    // Generate the sound using additive synthesis
    sig = Mix(SinOsc.ar(freqs, 0, amps));
    sig = sig * env;
    
    // Apply waveshaping
    sig = Shaper.ar(Buffer.read(s, "path-to-buffer.wav"), sig);
    
    // Panning
    sig = Pan2.ar(sig, pan);
    
    Out.ar(0, sig);
}).add;
)