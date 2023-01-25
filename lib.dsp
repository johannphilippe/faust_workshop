/*
	Quelques fonctions utiles que j'ai fabriquées 
*/
import("stdfaust.lib");

round(sig) = floor(sig), ceil(sig) : select2( (sig -floor(sig)) > 0.5 ); 

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
wavefolder(sig) = 4 * (abs(0.25 * sig + 0.25 - round(0.25 * sig + 0.25))-0.25)


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


