(
SynthDef(\dong, { arg outBus, pit = 60, trig = 0, struct = 0.25, bright = 0.5, damp = 0.7, pos = 0.25;
    Out.ar(outBus, MiRings.ar(pit: pit, trig: trig, struct: struct, bright: bright, damp: damp, pos: pos, poly: 4, model: 2));
}).add;

SynthDef(\cloud, { arg inBus, pit = 0, pos = 0, size = 0, dens = 0.4, tex = 0.5;
	var input;
	input = In.ar(inBus);
	Out.ar(0, MiClouds.ar(input, pit, pos, size, dens, tex, drywet: 0.5, mode: 0, fb: 0.4));
}).add;
)

(
var notes, on, off, cc, structCc, brightCc, dampCc, posCc;
var pitCc, cPosCc, sizeCc, densCc, texCc;

MIDIClient.init;
MIDIIn.connectAll;

e = Bus.audio(s, 1); // effects - maybe two channels?
r = Synth(\dong, [\outBus, e]);
c = Synth.after(r, \cloud, [\inBus, e]);

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	r.set(\pit, num, \trig, 1);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
    r.set(\trig, 0);
});

cc = MIDIFunc.cc({ |val, num, chan, src|
	[val, num, chan, src].postln;
});

// cc for rings
structCc = MIDIFunc.cc({ |val| r.set(\struct, val.linlin(0, 127, 0.0, 1.0)) }, 21);
brightCc = MIDIFunc.cc({ |val| r.set(\bright, val.linlin(0, 127, 0.0, 1.0)) }, 22);
dampCc = MIDIFunc.cc({ |val| r.set(\damp, val.linlin(0, 127, 0.0, 1.0)) }, 23);
posCc = MIDIFunc.cc({ |val| r.set(\pos, val.linlin(0, 127, 0.0, 1.0)) }, 24);
// cc for clouds
// pitCc = MIDIFunc.cc({ |val| c.set(\pit, val.linlin(0, 127, -48, 48)) }, 25);
texCc = MIDIFunc.cc({ |val| c.set(\tex, val.linlin(0, 127, 0.0, 1.0)) }, 25);
cPosCc = MIDIFunc.cc({ |val| c.set(\pos, val.linlin(0, 127, 0.0, 1.0)) }, 26);
sizeCc = MIDIFunc.cc({ |val| c.set(\size, val.linlin(0, 127, 0.0, 1.0)) }, 27);
densCc = MIDIFunc.cc({ |val| c.set(\dens, val.linlin(0, 127, 0.0, 1.0)) }, 28);


q = {
	on.free; off.free;
	cc.free;
	structCc.free; brightCc.free; dampCc.free; posCc.free;
	pitCc.free; cPosCc.free; sizeCc.free; densCc.free; texCc.free;
	r.free; c.free; e.free;
};
)

r.get(\struct, { arg value; value.postln; })
c.set(\size, 0);
c.set(\pit, 0);
c.set(\dens, 0.3);
c.set(\tex, 0.4);


// when done:
q.value;

(
{
    z = WhiteNoise.ar(0.2);
    z + AllpassN.ar(z, 0.01, XLine.kr(0.0001, 0.01, 20), 0.2)
}.play)