# Introduction 

* Pitch sur l'outil et sa signature : maïeutique 
* 

* Functional audio stream -> Langage de programmation audio/fonctionnel  -> Flux audio = rivière (programmer direct)
* Open-source et beaucoup plus concis que MSP
* De nombreux backends / targets 
	- Backend > génération de code
	- Target > Compilé

* Faust ne travaille QUE à l'échantillon.
* Faust est très pratique pour certaines choses, pas du tout pour d'autres
	- pratique pour des synthétiseurs, traitements dans le domaine temporel
	--très concis : écrire des gros algorithmes en peu de lignes
	- pas très pratique pour la FFT
	- pas très pratique pour le contrôle/gestion du temps 	

* Made with Faust - quelques exemples
* Langage DSP -> les possibilités de contrôle/composition sont minces

# 1. Le langage et la librairie

* Généralités sur la programmation : 
	- Suite d'expressions
	- Mathématiques -> nombres à virgule, entiers etc
	- Règle des priorités mathématiques
	- Opérateurs * / - + 
	- & | 
	- : , ! ~

	- Primitives / librairie
	- 

* Langage fonctionnel : description > Montrer une fonction

* Montrer le code généré

* Warning : Faust optimise le code (il retire le code mort)

* Introduire la librairie : pour éviter d'avoir à réinventer la roue
* faustide.grame.fr

## Les grands types de synthèse

* Additive
* Soustractive
* AM/FM
* Granulairoe

## GUI

* Slider, Button, checkbox, 
* Les UI sont en fait des entrées de contrôle

## Des applications plus complexes


## La gestion du temps 

* Tour d'horizon de la librairie standard 
* Solutions faites à la main

# 2. L'environnement

## Le graph - visualiser son DSP

## Les backends - compilation et génération de code
   DSP to C
   DSP to C++
   DSP to CSharp
   DSP to DLang
   DSP to FIR
   DSP to Interpreter
   DSP to Java
   DSP to Julia
   DSP to LLVM IR
   DSP to old C++
   DSP to Rust
   DSP to SOUL
   DSP to WebAssembly (wast/wasm)

* JSFX :D

## Les targets - VST, objet Max, standalone, Web
* Max > compiler des objets, ou user le jit llvm
* OSSIA score
* Csound
* Plugin (VST ou autre)
* Plein d'autre projets : https://synth.ameo.dev/


# 3. Cas pratique

* Ambisonie : librairies de Pierre Lecomte par exemple 
* Détecteur polyphonique : les limites de la politique du robinet "toujours ouvert"

# Conclusion


# Si encore du temps 
*  Réinventer la roue : la fabrique d'un oscillateur
