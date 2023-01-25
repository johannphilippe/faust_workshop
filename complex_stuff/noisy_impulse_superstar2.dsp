import("stdfaust.lib");
freq = hslider("freq[acc: 2 1 -10 0 10]", 20, 20, 1000, 1) : si.smoo;
//freq = hslider("freq[acc: 2 1 -10 0 10]", 0, 0, 1, 0.001) : *(1000) : +(20) : si.smoo;
amp = hslider("amp", 0.5, 0, 1, 0.01) : si.smoo;
speed = hslider("metrospeed[acc: 1 0 -10 0 10]", 2.0, 2.0, 20.0, 0.1) : si.smoo;
//drunk = hslider("drunk[acc:2 0 -10 0 10]", 4, 0, 6, 0.1);
drunk = speed/2.25;

diocles(a, x) = sqrt(pow(x, 3.0)/(2*a-x));

phaser(r,d) = _<: _,de.fdelay((os.osc(r)*0.5*d+0.5)*800+500,1001):>_*0.5;

beat(fq) = incr<=fq
with {
    incr = (_,smps : fmod) ~ +(1.0);
    smps = ma.SR/fq;
};

recdel(max_smps, smps, fb) = +~de.delay(max_smps,smps) * fb;
// Can be mixed with dry signal
mix_recdel(mix, max_smps, smps, fb, sig) = sig : recdel(max_smps, smps, fb) :
        _*mix + sig * (1 - mix); 

// Accentuation of one on several beats (simple counter and modulo)
accent(modulo, beat) = _~+( beat > beat' ) : %(modulo) : ==(0);

drunk_beat(fq, noise_amt) = beat(frq)
with {
    trig = beat(fq)|(fq!=fq')|os.impulse;
    frq = fq + (no.noise * noise_amt) : ba.sAndH(trig);
};

bt = drunk_beat(speed, drunk);
env = bt: en.are(0, 0.3);
MAXDEL = 8000;

del = hslider("delay[knob:2]", 1000, 500, MAXDEL/2, 1);

//del = int(abs(os.osc(0.01) * 5000 + 2000));
fb = hslider("feedback", 0.9, 0, 0.99, 0.01);
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
    'is_moving = threshed > 0;
    'dec =  (res / (release_time * ma.SR)) : *(-1) : ba.sAndH(is_moving);
    'mv = dec, inc : select2(is_moving);
    'res = (_:range(0,1))~+(mv);
};

mov = (freq+speed+delmod_amp) : capture_mov(0.05, 0.3);

mod = os.osc(speed)*0.5+1.0;
delmod_amp = hslider("delmod_amp[acc: 0 0 -10 0 10]", 0, 0, 1, 0.01);
dmod = mod * del * delmod_amp;
synt = os.sawtooth(freq+freq*mod) * env * mov
    : phaser(1, 0.5)
    : mix_recdel(0.3, MAXDEL, del+dmod, fb) 
    : mix_recdel(0.2, MAXDEL, del*0.5+dmod, fb)
    : mix_recdel(0.2, MAXDEL, del*0.75+dmod, fb)
    : fi.dcblocker
    ;

process = synt * amp;
