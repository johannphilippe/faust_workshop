import("stdfaust.lib");                                                               
metro(fq) = metro_impl(fq, 0);
metro_swing(fq, swing) = metro_impl(fq,0) | metro_impl(fq, swing);
// Better implementation
metro_impl(fq, phase) = incr<=1.0
with {
    offset = (1.0-phase) * smps;
    incr = _~+(1.0) : +(offset) : _,smps : fmod;
    smps = ma.SR/fq; 
};

drunk_metro(fq, noise_amount) = metro(freq)
with {
    trig = metro(fq)|(fq!=fq')|os.impulse;
    freq = fq + (no.noise*noise_amount) : ba.sAndH(trig);
};

// Pulsar synthesis from https://nathan.ho.name/posts/pulsar-synthesis/
pulsar(fq, form_fq, sine_cycles) = sine
with {
    pulsaret_phase = os.phasor(1, fq) * form_fq / fq;
    gate = (pulsaret_phase < 1);    
    window =  pulsaret_phase^4,0 : select2(gate > 1);
    sine = sin(pulsaret_phase * 2 * ma.PI * sine_cycles) * window * gate;
};

line(time, sig) = res
letrec {
	'changed = (sig' != sig) | (time' != time);
	'steps = ma.SR * time;
	'cntup = ba.countup(steps ,changed);  
	'diff = ( sig - res);
	'inc = diff / steps : ba.sAndH(changed);
	'res = res, res + inc : select2(cntup <  steps);
};
// From supercollider LFNoise
//Generates quadratically interpolated random values at a rate given by the nearest integer division of the sample rate by the freq argument.
random_lfo(freq_bef, mul, add, static_probability) = sig * mul + add
with {
    mod = os.osc(freq_bef / 10) : *(0.5) : +(0.50001);
    freq = freq_bef - (mod * 0.1);
    dmetro = drunk_metro(freq, 0.8);
    dmetro_inc = no.noise : abs : *(100) : ba.sAndH(dmetro);
    dmetro_cond = dmetro_inc < static_probability;
    static = no.noise : abs : ba.sAndH(dmetro) : ^(4);
    noiz = no.noise : abs;
    beat = ba.beat(60 * freq);
    pick = noiz : ba.sAndH(beat);
    cycle_dur = 1.0 / freq; // in seconds
    cycle_dur_smps = cycle_dur * ma.SR;
    linear = line(cycle_dur, pick);
    quad = linear^4;
    sig = quad, static : select2(dmetro_cond);
};


random_pulsar(fq) = pulsar(freq, formant_freq, sine_cycles)
with {
    freq = random_lfo(fq, 1000, 1, PROB);
    formant_freq = random_lfo(fq, 8000, 2, PROB);
    sine_cycles = int(random_lfo(fq, 3, 1, PROB));
    PROB = 10;

};

/*
freq = hslider("frequency", 100, 50, 500, 0.1) : si.smoo;
formant_freq = hslider("formant_freq", 100, 50, 10000, 0.1) : si.smoo;
*/
amp = hslider("amp", 0.1, 0, 1, 0.001) : si.smoo;

rnd_int(vmin, vmax) = no.noise : ba.sAndH(os.impulse) : *(vmax-vmin) : +(vmin) : floor;
process = par(n, 3, random_pulsar( rnd_int(1,3)* (n+1) ) : sp.panner(n/2.0)) :> _*amp, _*amp ;
