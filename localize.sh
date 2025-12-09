find . -type f -name "*.html" -mindepth 2 -maxdepth 2 -exec perl -0777 -i -pe 's/(href|src)="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/)[^"]+\/(?<!feed\/))"/$1="$2index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 3 -maxdepth 3 -exec perl -0777 -i -pe 's/(href|src)="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/)[^"]+\/(?<!feed\/))"/$1="..\/$2index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 4 -maxdepth 4 -exec perl -0777 -i -pe 's/(href|src)="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/)[^"]+\/(?<!feed\/))"/$1="..\/..\/$2index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 5 -maxdepth 5 -exec perl -0777 -i -pe 's/(href|src)="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/)[^"]+\/(?<!feed\/))"/$1="..\/..\/..\/$2index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 6 -maxdepth 6 -exec perl -0777 -i -pe 's/(href|src)="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/)[^"]+\/(?<!feed\/))"/$1="..\/..\/..\/..\/$2index.html"/mg' {} \;

find . -type f -name "*.html" -exec perl -0777 -i -pe 's/mage" content="(?:\.\.\/)*((?!http)[^"]+)"/mage" content="https:\/\/baka-bon.github.io\/doctruyen14\/$1"/mg' {} \;
