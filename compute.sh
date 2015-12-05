#!/bin/bash

GITREPO=/var/www/blog_data/
BLOG=/var/www/site/blog/
SITE=/var/www/

#File containing the list of posts
HF=$GITREPO"tmp.compute.md"
OUTHF=$BLOG"/index.html"

# --------------------------------------------
# - HF
touch $HF
echo "# Documents disponibles \/ Documents available" > $HF
echo "## List of pages / Liste des pages" > $HF
echo >> $HF
echo "  * [Liste des developpements d'agregation](/site/blog/pages/agreg_dev.htmt)" >> $HF
echo >> $HF
echo "## List of posts / Liste des billets" >> $HF
echo >> $HF

# --------------------------------------------
# - Posts
function pan {
    echo "pandoc -s --mathjax $1 -B header.html -A footer.html -c bootstrap.css -o $2"
    tail -n +4 $1 | pandoc -s --mathjax -c $SITE/bootstrap/bootstrap.min.css -c $SITE/style.css -A $SITE/footer.html -B $SITE/header.html -t html5 -o $BLOG$2
    # Post processing
    if [ -f $BLOG$2 ]; then
	TITLE=$(head -n 1 $1 | cut -d ' ' -f 2-)
	DATE=$(head -n 3 $1 | tail -n 1 | cut -d ' ' -f 2-)
	DATEF=$(echo $DATE | sed "s,/,\\\/,g")
	echo $TITLE" - "$DATE
	# H3 -> H4
	sed -i "s#<h3#<h4#g" $BLOG$2
	sed -i "s#</h3>#</h4>#g" $BLOG$2
	# H2 -> H3
	sed -i "s#<h2#<h3#g" $BLOG$2
	sed -i "s#</h2>#</h3>#g" $BLOG$2
	# H1 -> H2
	sed -i "s#<h1#<h2#g" $BLOG$2
	sed -i "s#</h1>#</h2>#g" $BLOG$2

	sed -i "s#<!-- Content : -->#<div class=\"page-header\"><h1>$TITLE - $DATEF</h1></div>#g" $BLOG$2
	sed -i "s#<title></title>#<title>$TITLE</title>#g" $BLOG$2

    fi
    # Add to post list :
    echo "  * "$DATE" - ["$3" - "$TITLE"](/site/blog/"$2")" >> $HF
}

cd $GITREPO
echo "Update git repository :"
git pull

echo "Entering posts"
cd posts
for i in $( ls -t); do
    if [ -d $i ]; then
	echo "Entering $i"
	cd $i
	mkdir -p $BLOG"posts/"$i
	if [ -f "fr.md" ]; then
	    echo "	fr.md"
	    pan "fr.md" "posts/"$i"/fr.html" "FR"
	fi
	if [ -f "en.md" ]; then
	    echo "	en.md"
    	    pan "en.md" "posts/"$i"/en.html" "EN"
	fi
	if [ -d "data" ]; then
	    DIR=$BLOG"posts/"$i"/"
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

pandoc -s $HF -c $SITE/style.css -c $SITE/bootstrap/bootstrap.min.css -A $SITE/footer.html -B $SITE/header.html -t html5 -o $OUTHF
#Change the dongle to Teaching
sed -i "s!<li class=\"active\"><a href=\"/\">Home</a></li>!<li><a href=\"/\">Home</a></li>!g" $OUTHF
sed -i "s!<li><a href=\"/site/blog/\">Blog</a></li>!<li class=\"active\"><a href=\"/site/blog/\">Blog</a></li>!g" $OUTHF
