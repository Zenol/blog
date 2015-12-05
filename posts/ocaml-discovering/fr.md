Title: 
Author: J�r�my
Date: 2009/11/21

D�couverte d'OCAML
==================

Dans ce petit article, je compte vous parler d'un langage de programmation assez particulier :  (O)CAML. Tout d'abord, si j'ajoute une parenth�se devant la premi�re lettre du sigle, c'est que je ne compte pas aborder toute la partie OBJET de langage, ni la partie imp�rative. (N'esp�rez pas voir une seul structure conditionnel[if] ou it�rative[while/for] dans ce texte.

Propositions : d�finitions et expressions :
===========================================

Tout comme en math�matique chaque phrase est une proposition, en ocaml chaque "ligne" est une proposition. Elle commence avec le premier caract�re et se termine avec le symbole ';;'

Il y a deux type de propositions :
 *  Les expressions : De la forme $3*7$ ou encore $\sqrt[7]{\frac{2^9}{3^{43}}}$
 *  Les d�finitions : De la forme $q := \sqrt{2}$ qui d�clare q comme un alias de $\sqrt{2}$

En ocaml, la syntaxe est la suivante :
 *  Pour un expression : 
    ```{.ocaml}
    3 * 7;;
    ```
    ou encore (pour $e^{log(\frac{exp(log(2) * 9)}{exp (log(3) * 43)}) / 7}$)
    ```{.ocaml}
    exp (log (exp(log 2. *. 9.) /. exp(log 3. *. 43.) ) /. 7.);;
    ```
 *  Enfin, une d�finition :
    ```{.ocaml}
	let q = sqrt 2;;
	```

L'aspect fonctionnel
====================

Mais comment un tel langage peut-il exister, et surtout, �tre 'utilisable' sans pour autant faire usage des structures des langages imp�ratif comme le C ou le Python? (Je m'adresse bien-sur ici a ceux qui n'ont pas encore �t� initier aux joies des langages fonctionnel)

Tout d'abord, d�finissons ce qu'est un langage fonctionnel. Par analogie � un langage objet o� les �l�ments sont des objets(Dans certains cas, TOUS les �l�ments), dans un langage fonctionnel, les �l�ments sont des fonctions, au sens math�matique du terme.

Si l'on consid�re la fonction suivante : $\begin{array}{ccccc} f & : & \mathbb{Z} & \to & \mathbb{Z}^2 \\ & & x & \mapsto & (x, x) \end{array}$

C'est la fonction qui associe � un entier $x$ son couple situer sur sa diagonal(injection diagonal) $(x,x) \in \Delta\mathbb{Z} \subset \mathbb{Z}^2$

Il est alors tr�s ais� de d�finir f en ocaml :
```{.ocaml}
let f x = (x, x);
```
Cette fonction est de type `int -> int * int`, c'est a dire qu'elle prend un entier $int \approx \mathbb{Z}$ et retourne un couple $(x, y) \in \mathbb{Z} \times \mathbb{Z}$.

On peut bien-sur d�finir des fonctions de fonction. Observons la fonction "composition"(rond) : $\begin{array}{ccccc} o & : & (\mathbb{B} \Rightarrow \mathbb{C} ) \times (\mathbb{A} \Rightarrow \mathbb{B} ) &amp; \longrightarrow &amp; (\mathbb{A} \to \mathbb{C} ) \\ & & (f, g) & \longmapsto & (x \mapsto f(g(x)) \end{array}$.

En OCAML, on aurais :
```{.ocaml}
let o f g = f g;;
(* val o : ('a -> 'b) -> 'a -> 'b = <fun> *)
```

Les filtres
===========

Je vous ai parler un peut plus t�t de l'absence de structures conditionnel et it�ratif, je vais ici vous exposer les solutions a votre disposition.

Commen�ons avec les blocs conditionnel. En OCAML, nous disposons d'une fonction-alit�e tr�s int�ressante : les filtres.
Si l'on consid�re la fonction continue suivante : $\begin{array}{ccccc} f & : & \mathbb{Z} & \to & \mathbb{Z} \\ & & x & \mapsto &
\left\{
\begin{array}{ccc}
x < 0 & \Rightarrow & -2x \\ x \ge 0 &  \Rightarrow & x^2
\end{array}
\right.
\end{array}$

On constate que l'on a bien deux condition, une premi�re qui regroupe les cas des x n�gatif, et une deuxi�me qui s'int�resse aux x restant. En OCAML, on d�fini de la m�me fa�on :
```{.ocaml}
let f = function
  | x when x < 0 -> -2 * x
  | x when x >= 0 -> x*x
  ;;
```
Ou bien, en omettant la deuxi�me condition et en consid�rons que la derni�re condition matcheras pour "tous les cas restant"
```{.ocaml}
let f = function
  | x when x < 0 -> -2 * x
  | x -> x*x
  ;;
```

Dans le cas o� l'on a pas besoin de nommer x, on peut utiliser _. Ainsi, un dernier cas `_ -> smtg` correspondrais un peut � 'default' d'un switch.
On pourras aussi utiliser l'instruction match {variable} with {filtre}.

La r�cursivit� terminal
=======================

Maintenant, consid�rons les it�rations. Nous allons utiliser la r�cursivit�s terminal(tail-rec pour les intimes) affin de construire une boucle. La r�cursivit�e terminal est une forme de r�cursivit� ou l'unique action qui succ�de � l'appelle a la fonction r�cursive est un retour de valeur.

C'est plut�t �l�mentaire : 
```{.ocaml}
let rec aff_n = function
  | n when n < 1 -> ();
  | n -> print_endline (string_of_int n);
           aff_n (n - 1);;
```
() repr�sente le type 'unit', c'est a dire que notre fonction ne retourne rien, tout comme print_endl. Nous obtenons une boucle de 10 � 1, et nous affichons les valeurs a l'�cran.
Vous vous demandez alors, pourquoi de la tail rec et non une simple r�cursivit�s? La r�ponse est que l'interpr�teur/compilateur optimise par une it�ration, ce qui est bien plus pratique pour nos machines qui on une m�moire limiter et ne peuvent supporter qu'un nombre restreins d'appelles r�cursif.

Pour conclure
=============

OCAML est un langage fonctionnel, qui bon nombre d'aspects et concepts qui sont parfois inconnus des programmeurs aillant pratiquer uniquement des langages imp�ratif, et constitue de par son existence une forme de culture dont il peut-�tre bon d'avoir connaissance.

R�f�rences :
============

Si vous �tes curieux et d�sirez en savoir plus, voici quelques liens :

 *  [Pr�sentation d'ocaml](http://www.iie.cnam.fr/~dubois/presentation_caml.pdf)
 *  [Notes on OCaml](http://www.csc.villanova.edu/~dmatusze/resources/ocaml/ocaml.html)
 *  [Wikipedia](http://fr.wikipedia.org/wiki/Objective_Caml)
 *  [Google](http://www.google.fr/search?&q=Tuto+Ocaml)
