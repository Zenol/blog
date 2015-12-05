Title: Calculer $a^n$ en temps $log_2(n)$
Author: Jérémy Cochoy
Date: 2009/10/19

Introduction
============

Aujourd'hui, un petit article sans grande prétention pour évoquer une petite astuce que je dois à mon prof d'algo.


__Trouvez un algo de calcul de $a^n\mid n\in\mathbb{N}, a\in\mathbb{R}$ avec un complexité inférieur à n__

En réalité, ce n'est pas si compliqué. b peut se décomposer aisément en puissances de deux via un masque binaire que l'on fait courir de droite à gauche, jusqu'à ce que la valeur de ce masque dépasse n. A chaque décalage du masque, on met au carré une même variable initialisée avec $a$ et si $masque \& b \not= 0$ on multiplie le résultat actuel par cette dernière.

Concrètement :
==============

```{.c}
#define MATH_IF(r, a, b)        ((1 - (r)) * (b) + (r) * (a))

//Décompose b en puissances de deux
// ex: a^7 = a^(1+2+4) = a^(1*2^0 + 1*2^1 + 1*2^2)
//Decimal<->Binaire 7dec = 111b
//On fait courir un masque de droite a gauche, et si le bit est actif,
// on ajouter la puissance de deux(donc un multiplie par a^mask)
int     npow(int a, int b)
{
  int   r;
  int   v;
  int   pw;
  int   mask;

  //n^0 = 1
  if (b &lt; 0)
    return 1;

  //pw = a^(2*k) and start at a^1 (k = 0)
  pw = a;
  //We will store result in v
  v = 1;
  //Binary mask, moving from right to left
  mask = 1;
  while (mask &lt;= b)
    {
      //Are there a bit set?
      r = (mask &amp; b) &amp;&amp; 1;

      //if r, v = v * pw
      v = MATH_IF(r, v * pw, v);

      //Move mask to left
      mask &lt;&lt;= 1;
      //pw = pw^2 (k++)
      pw = pw * pw;
    }
  return v;
}
```

Voila, c'est le genre de petites curiosités algorithmique amusantes.