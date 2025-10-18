// SC CODE
(
SynthDef(\humid_weather, {
    |out=0, amp=0.1, freq=440, decay=2|
    var env, sig, reverb;

    // Noise source to simulate rain
    var noise = PinkNoise.ar(0.5);

    // Envelope to shape the noise
    env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);
    sig = noise * env;

    // Adding reverb to simulate space/room
    reverb = FreeVerb.ar(sig, mix: 0.7, room: 0.9, damp: 0.5);

    // Output the sound with amplitude control
    Out.ar(out, reverb * amp);
}).add;
)


a = Synth(\humid_weather)