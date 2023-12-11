import("stdfaust.lib");

frequency = hslider("freq", 0.1, 0.001, 20, 0.001); 
duty = hslider("duty", 0, 0, 1, 0.01);
// PWM stands for Pulse Width Modulation (modulation à largeur d'impulsion)
pwm(freq, duty) = *(os.lf_pulsetrainpos(freq, duty) : si.smooth(0.99));

process = pwm(frequency, duty);