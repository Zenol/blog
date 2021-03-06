---
title: GDT et IDT
author:
- Jérémy Cochoy
date: 2009/04/20
...

Bonjour,

Depuis hier, KoS dispose enfin d'une gestion précaire des interruptions.
Dans cette article je vais donc... parler des interruptions!
Et histoire de ne perdre personne, je décrirais d'abord le fonctionnement de la
GDT.

1 : Physique ou Virtuelle
=========================

Si vous avez déjà fait un peu d'assembleur, vous devriez savoir qu'un programme,
une fois en mémoire, est diviser en plusieurs segments :

 * Segment de code
 * Segment de donne
 * Stack

Pour accéder a ces différents segment, on dispose des Sélecteurs de Segment.
Ce sont des registre qui indiquent ou se situent les donnes.

Ainsi, pour accéder a l' octet numéro `0x03` du segment de code,
on peut écrire `cs::0x03`.
Quand le processeur démarre, il est en mode réelle.
C' est a dire que les sélecteurs de segment représentent une adresse physique.
(`0x73` représente l' adresse mémoire `0x730`)

Ce n' est pas vraiment super, tout le monde a accès a tout et n' importe quoi,
et en plus les registres sont limiter a 16bits...

Pour régler ce problème, il existe le mode protège,
ou le processeur est en 32Bits et ou les sélecteurs correspondent a un maillon
 de la GDT(J' y viendrais dans quelques lignes).

Dans le mode protéger, la valeur des sélecteurs correspond à
l' offset(Décalage par rapport a l'origine) de l' élément dans
la GDT(Global Descriptor Table).
Pour accéder au premier sélecteur de la GDT, on place donc 0x0 dans
un sélecteur de segment.
Pour le second, 0x8 (Chaque maillon est sur 64bits), et ainsi de suite.

2: Les interruptions
====================

Une interruption, c'est (dixit wikipedia) "un arrêt temporaire de
l'exécution normale d'un
[programme informatique](http://fr.wikipedia.org/wiki/Programme_informatique)
par le [microprocesseur](http://fr.wikipedia.org/wiki/Microprocesseur).

Les interruptions sont de deux type : matériel ou logiciel.

Une interruption matériel est typiquement l' appuis sur une touche du clavier.
Une interruption logiciel peut être l' appelle à
un syscall (un appel à write sous unix)

Pour associer une fonction(le sens informatique du terme) à chaque
interruption, il existe l' IDT(Interrupt Descriptor Table).

Chaque élément de l' IDT contient :

 * Un sélecteur, qui correspond aux éléments de la GDT
 * Un offset (pointeur sur fonction)
 * Des bits qui spécifie le TYPE du maillon

3 : IRQs
========

Et non, ce n'est pas terminer. C'est bien beau de configurer la GDT et l' IDT,
mais encore faut-il configurer le chipset qui s'occupe de prévenir le processeur
quand une interruption matériel a lieu.
Pour résumer, ce composent envoi une requête (IRQ=Interuption ReQuest)
au processeur quand un évènement a lieu.
En plus, il n' est pas un, mais ils sont deux, en cascade (Un esclave et un maître).

Une fois le tout configurer, on réactive les interruption et...
On cherche pourquoi ça n' a pas fonctionner :)

4 : Références
==============

Pour lire un peu de code, vous pouvez jeter un oeil au dépôt
 git <https://github.com/jeremycochoy/kos/>.
