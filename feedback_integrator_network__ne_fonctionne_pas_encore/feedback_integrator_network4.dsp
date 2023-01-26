import("stdfaust.lib");

// Faust matrix
//    (x - _) * G + _) ~ (_ <: si.bus(4)) : ! , _ // output path

// Matrix 
//  (x - _) * G + _) ~ (_ <: si.bus(4)) : ! , _ // output path

matrix(nvoice) = par(in, nvoice, _) : (mix_with_recursion <: par(out, nvoice, mixer(nvoice, out)))~(si.bus(nvoice))
with {
    noise_mult = 1000;
    noise(x) = no.noises(nvoice * nvoice, x) : ba.sAndH(os.impulse|trig) : *(noise_mult);
    mixer(N, out) = par(in, N, _ : fi.pole(0.99) : *(noise(in)) : fi.dcblocker : aa.clip(-1, 1)) :> _;
    mix_with_recursion = par(in, nvoice*2, _) : ro.interleave(nvoice, nvoice/2) : par(in, nvoice, _+_);
};
recmatrix(nvoice) = matrix(nvoice);

/*
Fader(in)		= ba.db2linear(vslider("Input %in", -10, -96, 4, 0.1));
Mixer(N,out) 	= hgroup("Output %out", par(in, N, *(Fader(in)) ) :> _ );
Matrix(N,M) 	= tgroup("Matrix %N x %M", par(in, N, _) <: par(out, M, Mixer(N, out)));

process = Matrix(8, 8);
*/
/*matrix(nvoice) = par(n, nvoice, _) 
                            <: par(n, nvoice*nvoice, _)
                            : par(x,nvoice,  sum(y, nvoice, _ : *(noise(x*nvoice+y)))) 
                            : (par(n, nvoice, _))

                            */

trig = (t > t')
with {
    t = button("trigger");
};

feedback_integrator_network(nvoice) = par(n, nvoice, _) : sum(x, nvoice,  par(y, nvoice, leaky_integrator : *(noise(x, y))) : post_processing)  ~(si.bus(nvoice))
with {
    noise_mult = 1000;
    noise(x, y) = no.noises(nvoice * nvoice, y + (x * nvoice)) : ba.sAndH(os.impulse|trig) : *(noise_mult);

    leaky_integrator = fi.pole(0.99);
    post_processing = fi.dcblocker : aa.clip(-1, 1);
};

// chaque sortie est le résultat d'une somme des entrées * leurs volumes


/*
feedback_integrator_network(nvoice) = par(x, nvoice, _ : fi.pole(0.99) : *(sum(y, nvoice, noise(x, y))) : fi.dcblocker : aa.clip(-1, 1)) :> _,_
with {
    noise_mult = 1000;
    noise(x, y) = no.noises(nvoice*nvoice, y + (x*nvoice)) : ba.sAndH(os.impulse) : *(noise_mult);
};
*/


amp = hslider("amp", 0.1, 0, 1, 0.01) : si.smoo;

oscfreq = hslider("oscfreq", 100, 1, 400, 1);
oscamp = hslider("oscamp", 0.1, 0, 1, 0.01) : si.smoo;
osc = os.osc(oscfreq) * oscamp;


input_trig = val
with {
    t = button("input_trig");
    tt = t > t';
    val = no.noise : ba.sAndH(tt) : abs : *(2.99)  : floor;
};

sigs = os.osc(oscfreq) , os.sawtooth(oscfreq), os.square(oscfreq) : select3(input_trig) : *(oscamp);


process = os.impulse + sigs <: recmatrix(4) :> _*(0.1 * amp), _*(0.1*amp);

