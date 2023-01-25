import("stdfaust.lib");                                                                             
range(vmin, vmax, sig) = res
with {
        low = vmin, sig : select2(sig >= vmin) ;
        res = vmax, low : select2(low <= vmax);
};

/*
        Returns 0 if below th.
*/
threshold(th, sig) = sig, 0 : select2(sig <= th);
/*
        Capture movement on a signal - outputs signal between 0 and 1
*/
capture_mov(th, release_time, sig) = res
letrec {
    'diff = abs(sig' - sig);
    'threshed = diff : threshold(th);
    'inc = threshed;
    'is_moving = threshed != 0;
    'dec =  (res / (release_time * ma.SR)) : *(-1);// : ba.sAndH(is_moving);
    'mv = dec, inc : select2(is_moving);
    'res = (_:range(0,1))~+(mv):range(0,1);
};


amp = hslider("amp", 0.3, 0, 1, 0.01);
freq = hslider("freq[knob:2]", 80, 80, 800, 0.1) : si.smoo;
wah = hslider("wah[acc: 1 0 -10 0 10]", 0, 0, 1, 0.001) : si.smoo;
mix_noise = hslider("mix[acc: 0 0 -10 0 10]", 0, 0, 1, 0.001) : si.smoo;
drive = hslider("drive[acc: 2 3 -10 0 10]",0,0,1,0.01) : si.smoo;
distortion = ef.cubicnl(drive,0);

mov = wah : capture_mov(0.0001, 0.5);

s1 = os.sawtooth(freq) : distortion * 0.8;
s2 = os.sawtooth(freq+(freq*no.noise))  : distortion * 0.8;
sig = (s1 * mix_noise) + (s2 * (1 - mix_noise));
synt = sig * mov : ve.crybaby(wah);

process = synt * amp;

