declare name            "faust_jo";
declare version         "1.0";
declare author          "Johann Philippe";
declare license         "MIT";
declare copyright       "(c) Johann Philippe 2022";

import("stdfaust.lib");

/*
	Impulsion with a specified duration. Can be retriggered.
*/
mpulse(smps_dur, trig) = pulsation
with {
    count = ba.countdown(smps_dur, trig);
    //count =  -(1)~_, smps_dur : select2(trig);
    pulsation = 0, 1 : select2(count > 0);
};
mpulse_dur(duration, trig) = mpulse(ba.sec2samp(duration), trig);

/*
	Euclidian function. Generates an euclidian rythm with 0;1 triggers
*/
euclidian(onset, div, pulses, rotation, phasor) = (eucval' != eucval) & (kph' != kph)
with {
    kph = int( (( (phasor + rotation) * div) % 1) * pulses);
    eucval = int((onset / pulses) * kph);
};

dur_smps_euclidian(onset, div, pulses, rotation, smps_dur, phasor) = euclidian(onset, div, pulses, rotation, phasor) : mpulse(smps_dur);


/*
	Wavefolder. 
*/
wavefold(sig) = do_transform(sig), sig : select2((sig > -1) & (sig < 1))
with {
    abs_sig = abs(sig);
    decimal = abs_sig - int(abs_sig);
    neg_plus_decimal = -1 + decimal;
    pos_minus_decimal = 1 - decimal;
    process_value(x) = 1 - decimal, -1 + decimal : select2(x);
    is_even = ((int(abs_sig) %2) == 0);
    is_positiv = sig >= 0;
    do_transform(sig) = process_value( (is_even & is_positiv) | ( (is_even == 0) & (is_positiv == 0)) );
};

/*
	Waveshaper with wavefolder.
*/
nonlinear_wavefold(amount, sig) = final
with {
	transfer_fct = waveform{-1, -1, 1, 1};
	fold = wavefold(sig);
	fold_sig = (fold + 1) / 2;
	nonlinear = transfer_fct, int(fold_sig * 4) : rdtable;
	final = (nonlinear * amount) + ((1 - amount) * fold);

};

/*
	Limit to range
*/
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

/*
	Linear interpolation of a signal
*/
line(time, sig) = res
letrec {
	'changed = (sig' != sig) | (time' != time);
	'steps = ma.SR * time;
	'cntup = ba.countup(steps ,changed);  
	'diff = ( sig - res);
	'inc = diff / steps : ba.sAndH(changed);
	'res = res, res + inc : select2(cntup <  steps);
};



// In frequencies
fq_to_bpm(fq) = 60 * fq;
bpm_to_fq(bpm) = bpm / 60;
metro(fq) = ba.beat(fq_to_bpm(fq));
swingmetro_par(fq, swing) = m1, m2
with {
    m1 = metro(fq);
    m2 = met
    with {
        sw = swing ; //range( 0, 1, swing);
        ph = os.hs_phasor(1, fq, m1);
        met = 0, 1 : select2(cond) : ba.impulsify
        with {
            cond = (ph >= sw) & (ph' <= sw);
        };
    };
};
swingmetro(fq,swing) = swingmetro_par(fq, swing) :> _;

// Outputs triggers on first output, and velocity (normalized) on second 
sequencer(t, freq) = (res > 0) * (ph != ph'), res
with {
    sz = t : _,!;
    ph = int(os.phasor(sz, freq)); 
    res = t, ph : rdtable;
};

// Can choose the number of steps to read
step_sequencer(t, size, freq) = (res > 0) * (ph != ph'), res
with {
    ph = int(os.phasor(size, freq)); 
    res = t, ph : rdtable;
};

// Tempo adjusts so each step is equivalent
beat_sequencer(t, size, freq) = (res > 0) * (ph != ph'), res
with {
    ph = int(os.phasor(size, freq / size)); 
    res = t, ph : rdtable;
};

 
// Tempo adjusts so each step is equivalent
swing_sequencer(t,tswing, size, freq) = ((res > 0) * (ph != ph')) | swing, res
with {
    ph = int(os.phasor(size, freq / size));
    sw = tswing, ph : rdtable; 
    phstep = os.hs_phasor(1, freq, sw != sw');
    swing = 0, 1 : select2(cond) : ba.impulsify
    with {
        cond = (phstep >= sw) & (phstep' <= sw);
    };
    
    res = t, ph : rdtable;
};
