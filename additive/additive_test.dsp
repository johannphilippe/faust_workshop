import("stdfaust.lib");

base_freq = hslider("base_freq", 100, 50, 1000, 0.1);
partiels_distance = hslider("distance", 1, 1, 10, 1);
N_PARTIELS = 10;

oscil(freq, amp) = os.osc(freq) * amp;

overall_amp = hslider("amp", 0.1, 0, 1, 0.001) : si.smoo;

simple_additive = sum(n, N_PARTIELS, oscil(base_freq*(n+1)*partiels_distance, 1.0/(n+1))) : *(overall_amp);
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

line(time, sig) = res
letrec {
        'changed = (sig' != sig) | (time' != time);
        'steps = ma.SR * time;
        'cntup = ba.countup(steps ,changed);
        'diff = ( sig - res);
        'inc = diff / steps : ba.sAndH(changed);
        'res = res, res + inc : select2(cntup <  steps);
};

random_lfo(freq_bef, mul, add, static_probability) = sig * mul + add
with {
    mod = os.osc(freq_bef / 10) : *(0.5) : +(0.5001);
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

mpulse(smps_dur, trig) = pulsation
with {
    count = ba.countdown(smps_dur, trig);
    //count =  -(1)~_, smps_dur : select2(trig);
    pulsation = 0, 1 : select2(count > 0);
};
mpulse_dur(duration, trig) = mpulse(ba.sec2samp(duration), trig);

free_oscil(bfreq, amp, speed) = os.osc(bfreq + random_lfo(bfreq/1000, bfreq, 0, 0)) : *(amp) : *(env)
with {
    env = ba.beat(speed) : mpulse_dur(0.05) : en.are(0.05, 1);
};

general_speed = hslider("speed", 60, 20, 200, 1);
complex_additive = sum(n, N_PARTIELS, free_oscil(base_freq * ((n+1)*0.2) , 0.1, (n+1)*(general_speed) )) : *(overall_amp);

process = complex_additive <: _,_ ;
