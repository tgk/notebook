// alternative approach with one rings that is plucked
(
SynthDef(\dong, { arg pit = 60, trig = 0, struct = 0.25, bright = 0.5, damp = 0.7, pos = 0.25;
    Out.ar(0, MiRings.ar(pit: pit, trig: trig, struct: struct, bright: bright, damp: damp, pos: pos, poly: 4, model: 2));
}).add;
)

(
var notes, on, off, cc, structCc, brightCc, dampCc, posCc;

MIDIClient.init;
MIDIIn.connectAll;

r = Synth(\dong);

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
	r.set(\pit, num, \trig, 1);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
    r.set(\trig, 0);
});

cc = MIDIFunc.cc({ |val, num, chan, src|
	[val, num, chan, src].postln;
});

structCc = MIDIFunc.cc({ |val| r.set(\struct, val.linlin(0, 127, 0.0, 1.0)) }, 21);
brightCc = MIDIFunc.cc({ |val| r.set(\bright, val.linlin(0, 127, 0.0, 1.0)) }, 22);
dampCc = MIDIFunc.cc({ |val| r.set(\damp, val.linlin(0, 127, 0.0, 1.0)) }, 23);
posCc = MIDIFunc.cc({ |val| r.set(\pos, val.linlin(0, 127, 0.0, 1.0)) }, 24);

q = { on.free; off.free; cc.free; structCc.free; brightCc.free; dampCc.free; posCc.free; r.free; };
)

r.get(\struct, { arg value; value.postln; })


// when done:
q.value;