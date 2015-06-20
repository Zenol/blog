Title: CMake - Mini howto
Author: J�r�my Cochoy
Date: 2013/06/30

Qu'est-ce que CMake ?
=====================

CMake est un utilitaire permettant de g�n�rer le "build process" d'un projet. C'est un outils du m�me genre que les autotools (aussi appel� pour des raisons que je tairai 'autohell') en

  * Plus simple � configurer
  * Plus r�cent (donc moins de fa�ons de proc�d� obscures)
  * Plus performant (dans le sens o�, avec cmake, compiler un projet � l'ext�rieur du repository est extr�mement simple et agr�able!)
  * Vous �tes libre d'organiser vos r�pertoires/fichier comme vous le d�sirez.

Il est bon aussi de savoir que CMake est capable de g�n�rer aussi bien des Makefiles que des fichiers de projet VC++ ou XCode (pas mal, hein?).

On a aussi une jolie progression en % de la compilation (et l'on peut toujours utiliser make -j42 pour faire chauffer les c�urs).

Comment on s'en sert ?
======================

On connais tous le _./autogen.sh_, _./configure_ puis _make && sudo make install_. Bien entendu, on produit tous les fichiers bien salle dans le dossier des sources, ce qui donne une magnifique liste de fichiers � ajouter au .gitignore du votre projet (ou tout autre fichier �quivalent pour svn / mercurial). Avec cmake, on peut reproduire le sch�ma des autotools via `cmake .` puis `make && sudo make install`. Mais mieux, vous pouvez (par exemple) faire `mkdir build && cd build` puis `cmake ..` et `make && sudo make install`. Dite bonjour a la propret� de votre projet gr�ce � CMake ;)

Comment �a fonctionne ?
=======================
C'est l� qu'est le plus beau. Configurer CMake pour un projet, g�rer les d�pendances de libs, g�n�rer les libs, voir m�me g�n�rer les packages (que ce soit des packages archlinux, debian ...). On prend tr�s vite en main, c'est claire, et la documentation est excellente.

Je ne vais pas d�tailler comment construire un fichier de config ; le [tutorial CMake](http://www.cmake.org/cmake/help/cmake_tutorial.html) le fait d�j� tr�s bien, et l'on trouve tout ce qu'il manque dans le wiki. (Notez que dans un VRAI projet, il vous faudra un peu plus que le tutorial). Je vais aborder les id�es g�n�rales et les petites astuces qui m'ont servies.

D'abord, on place les instructions dans un fichier CMakeLists.txt a la racine du projet. On �vite donc la multiplication des fichiers de configuration. Il est possible d�appeler des scripts d'autres dossier gr�ce � `add_subdirectory("${PROJECT_SOURCE_DIR}/your_folder"`). Il est important d'utiliser `${PROJECT_SOURCE_DIR}` pour que tout se place bien quand on souhaite compiler dans un autre dossier.

On peut facilement demander a cmake de trouver des libs. En r�gle g�n�rale, on trouve un FindNomDeLaLib.cmake que l'on placera dans projet/cmake/Modules/, et l'on prendras soin d'ajouter `set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")`.

Une fa�on pratique pour compiler votre projet est de placer tous vos .c/.cpp dans un dossier src, et de tous les s�lectionner (�a �vite d'oublier d'ajouter un .cpp a la liste des fichiers du projet). Avec `file(GLOB_RECURSE SOURCE_FILES src/*.cpp SRC)` le liste des fichiers figure dans la variable "SOURCE_FILES". Si il vous faut exclure certains fichiers, vous pouvez utiliser :
`file(GLOB_RECURSE UNWANTED_FILES src/FichierAExclure.cpp SRC)
list (REMOVE_ITEM SOURCE_FILES ${UNWANTED_FILES})`

Si vous �tes fan des tests unitaires, CMake propose une fa�on agr�able de lancer des tests avec :
`add_test (NAME NomDuTeste WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/repertoiredexecution" COMMAND "commande a executer")`
�a vas de "lancer un programme et v�rifier qu'il EXIT_SUCCESS" � "v�rifier que la sortie du programme contient cette expression".

Chose utile, que ne fournissent pas les autotools, c'est une fa�on unifi�e de g�rer le num�ro de version de l'application ; Toute les variables d'un CMakeListes peuvent �tre utiliser pour g�n�rer des fichiers � partir de templates (souvent le nom du fichier avec le suffixe .in). En pratique, on d�finit VERSION_MAJOR et VERSION_MINOR, puis on g�n�re un Version.h, un doxyfile, et on utilise les valeurs pour g�n�rer les noms des biblioth�ques export�s. C'est simple, intuitif, et tr�s bien expliqu� dans le tutoriel. Faire une release se limite alors a changer le num�ro de version dans un fichier, et de lancer la compilation pour obtenir les binaires et packages.

CMake dispose aussi d'un syst�me de macros, pour faciliter la vie des maintainers, et l'on comprend donc que de plus en plus de projets tendent � l'utiliser.

Un fichier de configuration emacs est disponible (depuis la doc de cmake) pour ajouter un "cmake-mode", et se charge avec, par exemple, `(load "~/.emacs.d/cmake-mode.el")`.

On peux aussi contr�ler la g�n�ration d'une documentation avec doxygen. Pour cela, on rajoute un CMakeListes dans un r�pertoire /doc. On demande � ce que doxygen soit pr�sent via `find_package(Doxygen)`. On �crit un fichier template doxygen.in de configuration, o� les valeurs � modifier sont de la forme @NOM_DUN_DEFINE@, et d�finies dans le fichier de fonfiguration CMake par `set(NOM_DUN_DEFINE pou�c)`. Ensuite, on peut facilement ajouter une r�gle "make doc" de la fa�on suivante :
```
if(DOXYGEN_FOUND)
  configure_file(${DOXYGEN_TEMPLATE_FILE}
    ${DOXYGEN_CONFIGURED_FILE}
    @ONLY
    )
  add_custom_target(doc
    ${DOXYGEN_EXECUTABLE}
    ${DOXYGEN_CONFIGURED_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating API documentation with Doxygen" VERBATIM
    )
endif(DOXYGEN_FOUND)
```
o� le @ONLY signifie que seul les mots entour� d'@ seront remplac� (Sinon, les ${SOMETHING} sont aussi affect�s).

Conclusion :
============

Ce qu'il faut retenir, c'est que CMake est simple � configurer, offre de nombreuses fonctionnalit�s, et laisse la possibilit� d'ajouter celles manquantes. Beaucoup de gens sont encore habitu� au ./configure, et sont effray� par cette nouvelle fa�on d'aborder ce probl�me. Pourtant, CMake est un r�el gain de temps, et l'on voit des gros projets comme KDE changer de build system pour CMake.� On peux m�me l'utiliser pour de minuscule projets (compiler les .cpp d'un dossier en un ex�cutable, sans d�pendances particuli�res, se fait avec un fichier de configuration de 3 lignes), et je vous encourage justement � le faire. Trois lignes pour avoir une gestion automatique des d�pendances des .h, g�n�ration des makefiles, le tout multiplateforme, ce n'est pas cher pay�.

Resources :

<http://en.wikipedia.org/wiki/CMake>
<http://www.cmake.org/cmake/help/cmake_tutorial.html>