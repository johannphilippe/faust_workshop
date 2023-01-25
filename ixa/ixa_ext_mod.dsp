import("stdfaust.lib");

round(sig) = floor(sig), ceil(sig) : select2( (sig -floor(sig)) > 0.5 ); 
wavefolder(sig) = 4 * (abs(0.25 * sig + 0.25 - round(0.25 * sig + 0.25))-0.25);

pulse(x, t) = 0, 1 :select2( t >= (x*0.5) & t < x ); 
weird_wave(t) = (2 * pulse(0.5, t) - 1)*sin( 2*ma.PI * fmod(t, 0.5))
                    + 2 * pulse(0.5, t + 0.25)
                    + 2 * pulse(1, t + 0.5)
                    + 0.5;
tri(t) = t, 2-t, t-4 : select3( (t > 1) + (t > 3) );

ixa_modulator(r, t) = sin(2*ma.PI*r*t);
ixa(n, r, t) = tri(weird_wave(t)+n*sin(2*ma.PI*r*t)) : wavefolder;
ixa_ext_mod(n, t, mod) = tri(weird_wave(t) + n * mod) : wavefolder;

freq = hslider("frequency", 100, 50, 1000, 1);
amp = hslider("amp", 0.1, 0, 1, 0.01) : si.smoo;
index = hslider("index", 0, 0, 10, 0.001) : si.smoo;
ratio = hslider("ratio", 1, 1, 10, 0.01) : si.smoo;
osc = os.osc(freq);

mod_fq = hslider("mod_fq", 1, 1, 100, 1);
mod_index = hslider("mod_index", 1, 0, 10,0.01 );
// 
process = ixa_ext_mod(index, os.phasor(1, freq), ixa( mod_index, ratio, os.phasor(1, mod_fq))) * amp; //ixa( 0, ratio,os.phasor(1, freq)) * amp;
