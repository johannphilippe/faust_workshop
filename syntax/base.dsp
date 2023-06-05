// In Faust, expressions all end with semicolon;


// Each Faust DSP must contain the process function. It is the audio processor.
process = 0;

// Comments can be written in on line like this with // at the beginning
/*
	Or two lines with /* to begin and */ to end
*/

//Traditional syntax
process = 1 + 0.5;

// Sequential composition : the "+" operator has two inputs and one output.
process = 1, 0.5 : +;


//Parallel signals 
process = 1, 2, 3;

// Exactly the same, written with "par" iteration (means parallel), generating 3 voices 
process = par(n, 3, n+1);



