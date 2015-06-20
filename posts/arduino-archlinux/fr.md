Title: Arduino Uno sous ArchLinux (3.8.4-1-ARCH)
Author: J�r�my Cochoy
Date: 2013/03/31

Voil� que je ressort mon arduino de mes cartons, motiv� � d�poussi�rer le code de ma 'boite musicale'. Et quel ne fut pas ma surprise quand le package rxtx refusa de s'installer suite a des erreurs de compilation.

Vous commencez s�rement � me conna�tre ; je n'ai pas abandonn� pour si peu. Voil� donc que je me retrouve a publier ce petit billet, accompagn� des instructions pour patcher et installer la derni�re version de rxtx sous votre syst�me :)


�tape 1 : Arduino package
=========================

Installez le package arduino en utilisant la commande yaourt :

``` {.shell}
yaourt -S arduino
```

�tape 2 : T�l�charger, patcher et installer rxtx
================================================

Telechargez la pre-release depuis http://rxtx.qbang.org/wiki/index.php/Download :

``` {.shell}
wget http://rxtx.qbang.org/pub/rxtx/rxtx-2.2pre2.zip
unzip rxtx-2.2pre2.xip
cd rxtx-2.2pre2
```

Lancez configure avec l'option --disable-lockfile :

``` {.shell}
./configure --disable-lockfile
```


Ici, si vous tentez de compiler, vous aurez probablement une erreur `UTS_RELEASE` est ind�fini. Pour corriger ce probl�me, commencez par trouver le fichier utsrelease.h (`find /usr/ -name 'utsrelease.h'`). Pour ma part, il se trouvait dans `/lib/modules/3.8.4-1-ARCH/build/include/generated/`. Ensuite, incluez le dans config.h(C'est un fichier g�n�r� par configure), de facon � ce que la constant soit d�finie partout.

``` {.shell}
echo "\n#include \"/lib/modules/3.8.4-1-ARCH/build/include/generated/utsrelease.h\"\n" > config.h
```

Maintenant, on doit ajouter ttyACM � la liste des p�riph�riques. On modifit le fichier src/gnu/io/RXTXCommDriver.java en ajoutant une entr�e � un tableau (ttyACM). Regardez le fichier diff suivant :


``` {.shell}
--- src/gnu/io/RXTXCommDriver.java.back 2013-03-31 14:14:38.718567087 +0200
+++ src/gnu/io/RXTXCommDriver.java      2013-03-31 14:08:38.728149384 +0200
@@ -577,6 +577,7 @@
                                                "ttyS", // linux Serial Ports
                                                "ttySA", // for the IPAQs
                                                "ttyUSB", // for USB frobs
+                                               "ttyACM",// linux CDC ACM devices
                                                "rfcomm",       // bluetooth serial device
                                                "ttyircomm", // linux IrCommdevices (IrDA serial emu)
                                                };
```

The line marked with a plus is the one added.


Maintenant, compilez et installez!

``` {.shell}
make && sudo make install
```

Utilisez votre arduino
======================

Vous pouvez maintenant lancer l'IDE arduino (commande arduino) et charger un programme de test. Vous pouvez s�lectionner votre carte dans la liste des p�riph�rique, probablement sous le nom "ttyACM0".

Quelques infos
==============

On d�sactive l'option `--diseable-lockfile` pour faire dispara�tre des messages d'erreur parlant d'impossibilit� d'�crire les fichiers de lock. On ajouter le bon fichier .h contenant UTS_RELEASE pour �viter de stupide erreur de compilation (le fichier dans le quel est d�finit la macro a chang� r�cemment). Enfin, il est n�cessaire de modifier le code de rxtx (lisez les commentaires, vous verez qu'on vous demande explicitement de rajouter les devices manquant, en vous proposant la liste de tous ceux possible, et elle est bien longue!) pour que vous puissiez utiliser ttyACMx. Une autre solution serait d'ajouter un lien symbolique dans /dev/ d'un ttyUSBx vers un ttyACMx, par exemple (ttyUSB figure dans le tableau o`u nous avons ajouter ttyACM).

Bref, en fin de compte, si vous ne parvenez pas � utiliser votre arduino et que vous avez une erreur du type `processing.app.SerialNotFoundException: Port s�rie ��/dev/ttyACM0�� non trouv�`, c'est peut-etre tout simplement que ttyACM ne figure pas dans les p�riph�riques accept� par rxtx.

R�f�rences :
  * <http://arduino.cc/en/Guide/troubleshooting#toc1> Drivers / Linux.
  * <https://wiki.archlinux.org/index.php/Arduino>
