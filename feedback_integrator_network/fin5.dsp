/* This one is fun 
Has a delay piloted with oscillators that have random phases 
*/
import("stdfaust.lib");


wavefolder(sig) = 4 * (abs(0.25 * sig + 0.25 - rnd(0.25 * sig + 0.25))-0.25);
matrix(nvoice) = par(in, nvoice, _) : (mix_with_recursion <: par(out, nvoice, mixer(nvoice, out)))~(si.bus(nvoice))
with {
    noise_mult = 1000;
    noise(x) = no.noises(nvoice * nvoice, x) : ba.sAndH(os.impulse|trig) : *(noise_mult);
    mixer(N, out) = par(in, N, _ : fi.pole(leaky_factor) : *(noise(in)) : fi.dcblocker : de.fdelay(1000, os.oscp(delfq / noise(in), noise(in) / 1000) * noise(in) ) : aa.clip(-1, 1)) :> _;
    mix_with_recursion = par(in, nvoice*2, _) : ro.interleave(nvoice, nvoice/2) : par(in, nvoice, _+_);
};
recmatrix(nvoice) = matrix(nvoice);

delfq = hslider("delfq", 1, 0.0001, 10, 0.00001);
internal_del = hslider("delay_smps", 20, 1, 1000, 1);
leaky_factor = hslider("leak", 0.9, 0, 0.99999, 0.00001);

trig = (t > t')
with {
    t = button("trigger");
};


amp = hslider("amp", 0.1, 0, 1, 0.01) : si.smoo;

oscfreq = hslider("oscfreq", 100, 1, 4000, 1);
oscamp = hslider("oscamp", 0.1, 0, 1, 0.01) : si.smoo;
osc = os.osc(oscfreq) * oscamp;


input_trig = val
with {
    t = button("input_trig");
    tt = t > t';
    val = no.noise : ba.sAndH(tt) : abs : *(2.99)  : floor;
};

sigs = os.osc(oscfreq) , os.sawtooth(oscfreq), os.square(oscfreq) : select3(input_trig) : *(oscamp);


process = _ <: recmatrix(4) :> _*(0.1 * amp), _*(0.1*amp);
