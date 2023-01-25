declare options "[midi:on]";
import("stdfaust.lib");

freq = hslider("freq[midi:ctrl 11]", 100, 50, 500, 1);
process = os.osc(freq) * 0.1;
