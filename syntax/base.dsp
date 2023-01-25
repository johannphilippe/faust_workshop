// Chaque expression finit avec ;
process = 0;

// Chaque programme a une fonction process : c'est notre fonction audio. 

// Commentaires : // pour une ligne, 
       
/*
pour plusieurs lignes
*/

// Syntaxe traditionnelle
process = 1 + 0.5;

// Composition séquentielle : l'opérateur + prend deux entrées et a une sortie
process = 1, 0.5 : +;


//3 Signaux parallèles
process = 1, 2, 3;

// Idem
process = par(n, 3, n+1);



