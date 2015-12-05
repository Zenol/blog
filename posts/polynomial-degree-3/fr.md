Title: De la r�solution d'�quations polynomial de degr� 3
Author: J�r�my Cochoy
Date: 2011/02/25

La recherche de racine pour des polyn�mes du 3�me degr�
=======================================================

$$ Delta = b^2 - 4ac $$, voici une formule que la plupart d'entre vous on appris tr�s jeunes, et dont la simple lecture ou �coute �voque imm�diatement la r�solution de polyn�mes du second degr�.

Mais vous �tes vous d�j� paus� la question de la r�solution d'�quations mettant en jeu des polyn�mes du troisi�me degr�, ou pire, d'un degr� encore plus �lev�?

Sachez que pour les d�gr�es strictement sup�rieur � 4, les �quations ne sont alors plus "soluble par radicaux". Ce que l'on pourrais r�sumer � "finis les belles formules magiques au dessus du degr� 4".

Dans cette article, nous nous int�resserons � la m�thode de Tartaglia-Cardan, du nom de ces deux c�l�bres math�maticiens, respectivement a l'origine de la m�thode et de sa publication. (Je vous invite a en apprendre plus sur nos deux protagoniste, ainsi que Ferrari - le secr�taire de cardan - � qui l'on dois la r�solution des �quations de degr� 4 par radicaux.)

Nous chercherons � adapter la m�thode "papier" pour une application informatique, affin d'obtenir une valeur r�el avec une pr�cision convenable. Nous ne chercherons donc pas la r�ponse "exacte" comme l'on peut la trouver avec un crayon et beaucoup de papier.

Sachez que r�soudre des �quations de degr� 3 peut avoir de nombreuse applications, et que probablement certains de mes lecteurs souhaiteront la mettre en �uvre dans le cadre d'un raytracer d'ici la fin de l'ann�e scolaire. Plus que de donner une impl�mentation, je souhaite ici d�tailler la logique qui en est � l'origine.

�tape 1 ) Changement de variable
================================

La m�thode de cardan ne s'applique qu'� des polyn�mes de la forme $$ Z^3 + pZ + q = 0 $$ et nous cherchons une solution pour tout polyn�me de la forme $$ aX^3 + bX^2 + cX + d = 0 $$

On consid�reras donc deux cas : Notre polyn�me a son coefficient du second degr� nulle, et dans ce cas on n'effectue pas de changement de variable, on le rend juste unitaire(diviser par a). Dans le cas contraire, on pauseras $$ X = Z - \frac{b}{3a} $$, ce qui nous am�ne a calculer � calculer $$ p = - \frac{b^2}{3a^2} + \frac{c}{a} $$ et $$ q = \frac{b}{27a}\left(\frac{2b^2}{a^2}-\frac{9c}{a}\right)+\frac{d}{a} $$ (en d�veloppant le polyn�me $$ a(Z - \frac{b}{3a})^3 + b(Z - \frac{b}{3a})^2 + c(Z - \frac{b}{3a}) + d = 0 $$) , et par la suite ajouter $$ \frac{b}{3a} $$ a nos solutions.

Voici le code c correspondant :
```{.c}
int cardan(float a, float b, float c, float d, float resultat[3])
// -&gt; resultat est notre tableau de solutions
//Retourne le nombre de racines trouv�
{
  //Nos coefs
  float p;
  float q;
  //Ce que nous ajouterons a nos solution, si le changement de variable a eu lieu
  float correction = 0;

  //Si il n'y a pas besoin de changement de variable
  if (b == 0)
  {
    p = c / a;
    q = d / a;
  }
  //Sinon
  else
  {
    p = (-b * b / (3 * a) + c) / a;
    q = (b/(27 * a) * (2 * b * b / a - 9 * c) + d) / a;
    correction = -b/(3 * a);
  }
  //... see next block
```

�tape 2 ) Syst�me solution
==========================

Nous entrons enfin dans le vif du sujet. Comment allons nous maintenant trouver les racines de notre polyn�me? Pour commencer, nous savons qu'il existe au moins une racine r�el (Un polyn�me de degr� impaire admet toujours au moins une racine r�el) que l'on peut �crire sous la forme v + u, v et u deux r�els. (Car, �videmment, rien ne nous emp�che d'�crire 3 comme 2+1, ou 3+0!)

A ce stade, si nous d�veloppons notre polyn�me avec u+v, nous obtenons $$ v^3+u^3+(3uv+p)(u+v)+q=0 $$ (modulo une factorisation par (u+v) ).
Puisque nous pouvons "r�partir" notre solution "un peut dans u, le reste dans v" comme nous le souhaitons, rien ne nous emp�che de fixer $$ 3uv+p = 0 $$ (ou encore $$ uv = \frac{-p}{3u} $$

On remarque alors que notre polyn�me se simplifie, laissant appara�tre $$ u^3 + v^3= -q $$

En d'autre termes, notre solution est donc solution du syst�me $$ \begin{cases}u^3+v^3&amp;=-q\\ u^3v^3&amp;=-\frac{p^3}{27}\end{cases} $$ (et doivent respecter en plus la condition $$ 3uv+p = 0 $$).

Vous remarquerez alors que connaissant le produit et la somme de deux nombres a et b, nous pouvons nous servir du polyn�me du second d�gr�e $$ x^2 -(a + b)X + ab = 0 $$ qui a pour racines a et b. Appliquons ceci � $$ u^3 $$ et $$ v^3 $$

On r�sout donc $$ X^2+qX-\frac{p^3}{27}=0 $$. Attention, les solutions sont soit complexe, soit r�els, soit r�els double (u = v). Dans le cas de solutions pour u et v r�els, leur racine cubique est un r�el unique et nous aurons donc l'unique racine du polyn�me. Dans le cas de solutions complexe(non nulle) pour u et v, nous aurons alors 3 racines cubiques pour u et 3 pour v. Nous verrons dans le paragraphe suivant comment calculer ces racines et trouver les bonnes combinaisons.

Voici l'impl�mentation pour les racines r�els :
```{.c}
  // ... next block :
  float delta = q*q + 4 * p*p*p / 27; //On applique delta = b^2+4ac o� b=q, a=1, c = -p^3/27
  // Racine double r�el =&gt; 3 solutions r�els, dont une double
  if (delta == 0)
  {
    //En grattant beaucoup de papier, on parvient � calculer directement
    // les raine sans utiliser pow. Nous en profitons donc :
    float z1 = 3.f * q / p;
    float z2 = -3.f / 2.f * q / p;
    resultat[0] = z1 + correction;
    resultat[1] = z2 + correction;
    resultat[2] = resultat[1];
    //Finalement, ce polyn�me a 3 racines :
    return 3;
  }
  // Une unique solution r�el
  else if (delta &gt; 0)
  {
    //La racine carr� de delta :
    delta = sqrt(delta);
    //Nos solutions u et v :
    float u = (-q - delta) / 2.f;
    float v = (-q + delta) / 2.f;
    //On calcule alors leur racine cubique :
    u = pow(u, 1.f/3.f);
    v = pow(v, 1.f/3.f);
    // notre racine est donc u + v + correction
    resultat[0] = u + v + correction;
    //Finalement, ce polyn�me n'a qu'une racine :
    return 1;
  }
  else
  {
    //to be continue
```

�tape 3 ) Racines complexe : un peu de g�om�trie
================================================

Multiplier un complexe a par un complexe b, c'est obtenir un complexe c dont la norme est le produit de |a| et |b|, et l'argument la somme de arg(a) et arg(b). D'un point de vue g�om�trique, le produit de a par b est une rotation de a d'angle arg(b) dans le sens trigonom�trique, et une homoth�tie par le scalaire |b|. O� cela nous conduit-il? A la d�finition d'une racine cubique d'un complexe. Soit $$ a = |a|e^{arg(a)} $$ le complexe d'argument arg(a) et de norme |a|, on a pour racine cubique : $$ z_1 = \sqrt[3]{|a|}e^{arg(a)} $$ $$ z_2 = \sqrt[3]{|a|}e^{arg(a)/3 + 2\pi/3} $$  $$ z_3 = \sqrt[3]{|a|}e^{arg(a)/3 + 4\pi/3} $$

De fa�on g�n�rale, les racines ni�mes d'un complexe d'argument arg(a) et de norme |a| est la rotation de $$ \frac{arg(a)}{n} $$ et homoth�tie de scalaire $$ \sqrt[3]{|a|} $$ des racines ni�me complexe de 1 (pouvant elles m�me �tre consid�r� comme un polygone...)

Bref, de belles fa�ons d'interpr�ter les choses, mais en quoi cela nous aide-il?

Et bien, si nous pouvions conna�tre l'argument d'un complexe et son module, nous pourrions calculer num�riquement l'argument et le module de ses racines, et ainsi trouver les valeurs possible pour u et v. Consid�rons donc nos solutions complexe comme les points d'un plan. Le module et l'argument forment alors leur coordonn�es polaire. Nous avons le syst�me suivant qui lit les coordonn�es cart�siennes d'un point � ses coordonn�es polaire : $$ \begin{cases}x&amp;=r cos(alpha)\\ y&amp;=r sin(alpha)\end{cases} $$ De plus, nous pouvons calculer r, en appliquant le th�or�me de Pythagore. Si l'on fait alors le quotient de x par y, on obtient $$ tan(alpha) $$. En fait, en �tudiant le signe de x et de y, on peut connaitre le signe de alpha et donc utiliser atan (la r�ciproque de tangente, modulo le bonne ensemble de d�finition). (Pour se simplifier la tache en C, on peut utiliser la fonction tan2(x, y) qui effectue le quotient et tien compte des signes.)

Encore un dernier d�taille, et nous avons termin�. Les solutions que nous trouverons pour u et v peuvent se classer par paire de conjugu� (les racines de u et v correspondant a la m�me racine cubique de 1). On remarque alors que les solutions seront toute bien r�el. (La partie imaginaire de chacun des conjugu� s'annulant.) Bien, passons � l'impl�mentation :
```{.c}
  // ... last block :
    //On commence par prendre la valeur absolue de delta
    //Par la suite, on suppose delta &gt; 0.
    delta = -delta;
    //Petit rappelle, nos solutions sont de la forme : -q/2 +- i sqrt(delta)/2
    //Donc, de module au carr� r^2 = (-q/2)^2 + (sqrt(delta)/2)^2 = q^2/4 + (delta)/4
    //FInalement r = sqrt(q^2 + delta) / sqrt(4)
    //Calculons le module :
    float r = sqrt(q*q + delta) / 2;
    //Maintenant, l'argument de nos complexe. Si deux complexe sont des conjugu�, alors
    // ils on simplement leur argument de signe oppos�. Comme on peux indiff�remment inverser u et v, nous n'avons
    // pas besoin de tan2.
    // En simplifiant y / x, on trouve +-sqrt (delta) / q
    float alpha = atan(sqrt(delta) / q);
    // Nous calculons l'argument et le module d'une des racine complexe
    // (Celle au plus petit argument, c'est a dire Theta + 0PI/3)
    // Par la suite, alpha = theta et r = r^(1/3)
    r = pow(r, 1.f/3.f);
    alpha = alpha / 3.f;
    //Nous pouvons donc calculer nos trois racines r�els, en passant de coordonn�e polaire � des coordonn�es cart�siennes.
    //De plus, nous simplifions et ne calculons pas la partie imaginaire, qui comme expliqu� pr�c�demment est nulle
    resultat[0] = 2 * r * cos(alpha) + correction; //nous avons effectivement r*cos(alpha) + r*cos(alpha)
    resultat[1] = 2 * r * cos(alpha + 2*PI/3) + correction;
    resultat[2] = 2 * r * cos(alpha + 4*PI/3) + correction;
    return 3;
  }
}
//Ouf! C'est termin�!
```

Pour conclure, un petit coup de wikipedia vous montreras que l'on peut simplifier le calcule du module, et n'utiliser qu'une simple racine carr�e. Pensez aussi que si vous pouvez �viter de calculer deux fois la m�me chose, vous gagnerez en performance. Pensez a factoriser les expression de mani�re a ce que les produits/quotient soient r�solut � la compilation et cherchez a minimiser les produits/quotient.

Notez que celons le contexte, on pr�f�rera consid�rer une racine double qu'une seule fois, affin d'�viter la redondance des calcules.

Sur papier?
===========

Sachez que la m�thode papier consiste � effectuer le m�me raisonnement que j'ai men� jusqu'au calcule du discriminant du polyn�me qui nous permet de trouver a et b. Dans le cas _delta <= 0_, on calculeras la racine cubique et on factoriseras le polyn�me pour faire appara�tre les racines. Dans le cas de complexes, on pourras �tre amener a chercher les racines d'un nouveau polyn�me du 3�me degr� pour simplifier l'expression des racines. Bien que la m�thode de Tartaglia-Cardan soit une m�thode qui fonctionne parfaitement, il n'est pas toujours facile de calculer les racines d'un polyn�me de degr� 3.