(
SynthDef(\WindyLandscape, {
    var env, freq1, freq2, sound1, sound2, envGen1, envGen2, pan1, pan2, sound;

    // Envelope
    env = Env.new([0, 1, 1, 0], [0.01, 0.98, 0.01], \lin);

    // Frequencies for two melody lines
    freq1 = Demand.kr(Duty.kr(0.2, 0, Dseq((Scale.minor.degrees * (36..60)).midicps, 50)), 0, Dshuf((Scale.minor.degrees * (36..60)).midicps, 50));
    freq2 = Demand.kr(Duty.kr(0.2, 0, Dseq((Scale.minor.degrees * (36..60)).midicps, 50)), 0, Dshuf((Scale.minor.degrees * (36..60)).midicps, 50));

    // Sound generation for two melody lines
    sound1 = SinOsc.ar(freq1, 0, 0.1) * EnvGen.kr(env, doneAction: 2);
    sound2 = SinOsc.ar(freq2, 0, 0.1) * EnvGen.kr(env, doneAction: 2);

    // Panning
    pan1 = Pan2.ar(sound1, -0.5);
    pan2 = Pan2.ar(sound2, 0.5);

    // Combining sounds
    sound = Mix.new([pan1, pan2]);

    Out.ar(0, sound * 0.5); // Adjusting overall amplitude
}).add;
)