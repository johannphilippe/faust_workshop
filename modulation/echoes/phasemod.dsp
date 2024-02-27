import("stdfaust.lib");
//-----------------------------------------------
// Phase Modulation as an effect
//-----------------------------------------------
// os = library("miscoscillator.lib");

//import("../lib/common.lib");

tablesize = 1 << 16;

pmFXr = hslider("pmfxr",0.5,0,8,0.001):si.smooth(0.999);

PHosci(freq,PH)	=
s1 + d * (s2 - s1)
    with {
    i = int(phase(freq));
    d = ma.decimal(phase(freq));
    PHi = ma.decimal(i/tablesize +PH)*tablesize;
    sineWF = float(ba.time)*(2*ma.PI)/float(tablesize):sin;
    s1 = rdtable(tablesize+1,sineWF,int(PHi));
    // s1 = rdtable(tablesize+1,os.sinwaveform,int(PHi));
    s2 = rdtable(tablesize+1,sineWF,int(PHi+1));
    phase(freq) =
    (freq*pmFXr)/float(ma.SR):
    ((+:ma.decimal)~_)
    *float(tablesize);
    };

      // modulator:
      // usage:
      // ,pmFX(freq,pmFXr,pmFXi,PMphase)
      // ,pmFX(freq,pmFXr,pmFXi,0-PMphase)
pmFX(fc,r,I,PH,x) = x : de.fdelay3(1 << 17, dt + 1)
    with {
    k = 8.0 ; // pitch-tracking analyzing cycles number
    //fc = PtchPr(k,x) ;
    dt = (0.5 * PHosci(fc * r,PH) + 0.5) * I / (ma.PI * fc) *ma.SR ;
    };
    //process = pmFX(r,I) ;

fq = hslider("fq", 0.1, 0.001, 20, 0.001);
fxr = hslider("rate", 0, 0, 1, 0.01);
fxi = hslider("index", 0, 0, 1, 0.01);
process = _ : pmFX(fq, fxr, fxi, 0);
