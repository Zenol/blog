#!/bin/bash

GITREPO=/var/www/site/data/blog/
SITE=/var/www/site/blog/

#File containing the list of posts
HF=$GITREPO"tmp.compute.md"
OUTHF=$SITE"/index.htm"

# --------------------------------------------
# - HF
touch $HF
echo "# List of pages / Liste des pages" > $HF
echo >> $HF
echo "  * [Liste des developpements d'agregation](/site/blog/pages/agreg_dev.htm)" >> $HF
echo >> $HF
echo "# List of posts / Liste des billets" >> $HF
echo >> $HF

# --------------------------------------------
# - Posts
function pan {
    echo "pandoc -s $1 -A footer.html -c normalize.css -c bootstrap.css -o $2"
    tail -n +4 $1 | pandoc -s -c ../../normalize.css -c ../../bootstrap.css -A $SITE"/footer.htm" -t html5 -o $SITE$2
    # Post processing
    if [ -f $SITE$2 ]; then
	TITLE=$(head -n 1 $1 | cut -d ' ' -f 2-)
	DATE=$(head -n 3 $1 | tail -n 1 | cut -d ' ' -f 2-)
	DATEF=$(echo $DATE | sed "s,/,\\\/,g")
	echo $TITLE" - "$DATE
	sed -i "s/<body>/<body><div class=\"container\"><div class=\"page-header label\"><h1>$TITLE - "$DATEF"<\/h1><\/div>/g" $SITE$2
	sed -i "s/<footer id/<\/div><footer id/g" $SITE$2
	sed -i "s/<title><\/title>/<title>$TITLE<\/title>/g" $SITE$2

    fi
    # Add to post list :
    echo "  * "$DATE" - ["$3" - "$TITLE"](/site/blog/"$2")" >> $HF
}

cd $GITREPO
echo "Update git repository :"
git pull

echo "Entering posts"
cd posts
for i in $( ls); do
    if [ -d $i ]; then
	echo "Entering $i"
	cd $i
	mkdir -p $SITE"posts/"$i
	if [ -f "fr.md" ]; then
	    echo "	fr.md"
	    pan "fr.md" "posts/"$i"/fr.htm" "FR"
	fi
	if [ -f "en.md" ]; then
	    echo "	en.md"
    	    pan "en.md" "posts/"$i"/en.htm" "EN"
	fi
	if [ -d "data" ]; then
	    DIR=$SITE"posts/"$i"/"
	    mkdir -p $DIR"data/"
	    cp -r "data" $DIR
	    echo "cp -r \"data\" $DIR"
	fi
	cd ..
    fi
done
cd ..

# --------------------------------------------
# - HF

pandoc -s $HF -c normalize.css -c bootstrap.css -A $SITE"/footer.htm" -t html5 -o $OUTHF
sed -i "s/<body>/<body><div class=\"container\"><div class=\"page-header label\"><h1>Documents disponibles \/ Documents available<\/h1><\/div>/g" $OUTHF
sed -i "s/<footer/<\/div><footer/g" $OUTHF
sed -i 's/<head>/<head><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta name="viewport" content="width=device-width, initial-scale=1">/g' $OUTHF
