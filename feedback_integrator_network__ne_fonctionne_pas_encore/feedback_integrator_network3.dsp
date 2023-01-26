import("stdfaust.lib");

// Faust matrix
//    (x - _) * G + _) ~ (_ <: si.bus(4)) : ! , _ // output path

feedback_integrator_network(nvoice) = par(x, nvoice, sum(y, nvoice, leaky_integrator : *(noise(x, y))) : post_processing)  ~(si.bus(nvoice))
with {
    noise_mult = 1000;
    noise(x, y) = no.noises(nvoice * nvoice, y + (x * nvoice)) : ba.sAndH(os.impulse) : *(noise_mult);

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

rndosc = os.square(hslider("freq", 100, 50, 1000, 1) * (ba.beat(120) : en.are(0, 10))) * hslider("oscamp", 0, 0, 1, 0.01);

process = os.impulse <: feedback_integrator_network(4) :> _*(0.1 * amp), _*(0.1*amp);



