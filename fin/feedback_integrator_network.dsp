import("stdfaust.lib");

// Faust matrix 
N_VOICES = 8;
//    (x - _) * G + _) ~ (_ <: si.bus(4)) : ! , _ // output path
feedback_integrator_network(nvoice) =  _ : snd :> _,_
//~+(_<:si.bus(nvoice)) : (snd)) :> _,_
with {
    noise_mult = 1000;
    nz = no.multinoise(nvoice*nvoice);

    trig = ba.beat(60);
    noise(x, y) = no.noises(nvoice*nvoice, y + (x*nvoice)) : ba.sAndH(trig+os.impulse) : *(noise_mult);
    voice(x, sig) =( sig+_ : fi.pole(0.99) 
                : *(sum(y, nvoice, noise(x,y)))
                : fi.dcblocker 
                : aa.clip(-1, 1))~_;
    //snd = par(x, nvoice, _ : fi.pole(0.99) : *(sum(y, nvoice, noise(x,y))) : fi.dcblocker : aa.clip(-1, 1)) ;
    snd = _ <: par(x, nvoice, _ : (voice(x))) ;
};

amp = hslider("amp", 0.1, 0, 1, 0.01) : si.smoo;

rndosc = os.square(hslider("freq", 100, 50, 1000, 1) * (ba.beat(120) : en.are(0, 10))) * hslider("oscamp", 0, 0, 1, 0.01);
process = os.impulse+rndosc : feedback_integrator_network(4) : _*(0.1 * amp), _*(0.1*amp);
