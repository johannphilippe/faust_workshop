

// Inputs and outputs -> peuvent être représentées par le underscore. 
// Ici, le underscore est dans la boucle parallèle, il y a donc 8 entrées
// On merge en deux sorties
process = par(n, 8, _) :> _,_;
