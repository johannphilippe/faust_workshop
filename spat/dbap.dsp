declare name            "DBAP";
declare version         "1.0";
declare author          "Johann Philippe";
declare license         "MIT";
declare copyright       "(c) Johann Philippe 2024";

import("stdfaust.lib");

NSRC = 1; 
NSPEAKERS = 4;

/*
    DBAP - distance based amplitude panning 
    References : 
        - https://arxiv.org/pdf/2109.08704.pdf
            - where gain[i] = k*w[i]/d[i]^a
            - where k = 1 / w^2/d[i]^2*a for i = 1; i <= N (number of speakers)
            - where a = R / 20*log10^2  

            - where N is number of speakers, d is distance, w is weighting parameter (typically 1) 
                and a is coeffincient calculated from a rollof R in decibels and k is a coef function of the position of the source and the spakers

            - distance = sqrt((xi-xs)^2 + (yi-ys)^2 + (zi-zs)^2 + rs^2)
            - r[s] is spatial blur factor
*/

dbap_amps(nsrc, nspeakers, rolloff, rs) = amplitudes
with {
    src = srcpos(nsrc);
    x = ba.take(1, src);
    y = ba.take(2, src);
    z = ba.take(3, src);

    a(rolloff) = log(pow(10, (rolloff/20)))/log(2);

    distance(x,y,z, xspeaker, yspeaker, zspeaker, rs) = pow(x-xspeaker, 2) 
                                                        : +(pow(y-yspeaker, 2))
                                                        : +(pow(z-zspeaker, 2))
                                                        : +(pow(rs, 2))
                                                        : sqrt;
    dia(x,y,z, xsp, ysp, zsp) = pow(distance(x, y, z, xsp, ysp, zsp, rs), (0.5*a(rolloff))); 

    amplitudes = par(n, nspeakers, op(n) )
    with {
        dias = par(n, nspeakers, proc_dia(n))
        with {
            proc_dia(n) = dia(x, y, z, xsp, ysp, zsp) 
            with {
                speakerlist = speaker(n);
                xsp = ba.take(1, speakerlist);
                ysp = ba.take(2, speakerlist);
                zsp = ba.take(3, speakerlist);
            };
        };
        k = sqrt(1 / sum(n, nspeakers, dias : ba.selectn(nspeakers, n) ));
        op(n) = k / (dias : ba.selectn(nspeakers, n));
    };
};

/*
    dbap : 
    @arg NSRC is number of sources
    @arg NSPEAKERS is number of speakers 
    @arg rolloff is gain reduction factor in db
    @arg rs is width of source
    @arg srcs is a list of signal inputs
*/

dbap(NSRC, NSPEAKERS, rolloff, rs, srcs) = prod(n, NSRC, compute(n) )
with {
    compute(n) = par(n, NSPEAKERS, sig * amp(n) )
    with {
        amps = dbap_amps(n, NSPEAKERS, rolloff, rs);
        amp(x) = amps : ba.selectn(NSPEAKERS, x);
        sig = srcs : ba.selectn(NSRC, n);
    };
};

speaker(n) = (x, y, z)
with {
    x = hslider("speakerpos x %n", 0, -10, 10, 0.001 );
    y = hslider("speakerpos y %n", 0, -10, 10, 0.001 );
    z = hslider("speakerpos z %n", 0, -2, 5, 0.001 );
};

srcpos(n) = (x,y,z) 
with {
    x = hslider("srcpos x %n ", 0, -10, 10, 0.001 );
    y = hslider("srcpos y %n ", 0, -10, 10, 0.001 );
    z = hslider("srcpos z %n ", 0, -2, 5, 0.001 );
};

graphics(n, sig) = sig <: attach(_, (_ : abs : an.rms_envelope_rect(0.05)) : hbargraph("Amp_%n", 0, 1));

rolloff = hslider("rolloff", 3, 1, 12, 0.01);
rs = hslider("sourcewidth", 1, 0.1, 6, 0.01);

gain = hslider("gain", 0.1, 0, 2, 0.001);
amp = hslider("out_amp", 1, 0, 1, 0.001);

//process = dbap(src, NSPEAKERS, rolloff, rs) : par(n, NSPEAKERS, graphics(n));

process = par(i, NSRC, _ * gain ) : dbap(NSRC, NSPEAKERS, rolloff, rs ) : par(n, NSPEAKERS, graphics(n)) : par(i, NSPEAKERS, _ * amp);



