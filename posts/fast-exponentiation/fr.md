Title: Calculer $a^n$ en temps $log_2(n)$
Author: J�r�my Cochoy
Date: 2009/10/19

Introduction
============

Aujourd'hui, un petit article sans grande pr�tention pour �voquer une petite astuce que je dois � mon prof d'algo.


__Trouvez un algo de calcul de $a^n\mid n\in\mathbb{N}, a\in\mathbb{R}$ avec un complexit� inf�rieur � n__

En r�alit�, ce n'est pas si compliqu�. b peut se d�composer ais�ment en puissances de deux via un masque binaire que l'on fait courir de droite � gauche, jusqu'� ce que la valeur de ce masque d�passe n. A chaque d�calage du masque, on met au carr� une m�me variable initialis�e avec $a$ et si $masque \& b \not= 0$ on multiplie le r�sultat actuel par cette derni�re.

Concr�tement :
==============

```{.c}
#define MATH_IF(r, a, b)        ((1 - (r)) * (b) + (r) * (a))

//D�compose b en puissances de deux
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

Voila, c'est le genre de petites curiosit�s algorithmique amusantes.