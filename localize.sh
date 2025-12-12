#!/bin/bash

#find . -type f -name "*.html" -exec dos2unix {} \;

find . -type f -name "*.html" -mindepth 2 -maxdepth 2 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/))?"/href="$1index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 3 -maxdepth 3 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/))?"/href="..\/$1index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 4 -maxdepth 4 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/))?"/href="..\/..\/$1index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 5 -maxdepth 5 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/))?"/href="..\/..\/..\/$1index.html"/mg' {} \;
find . -type f -name "*.html" -mindepth 6 -maxdepth 6 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.vip\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/))?"/href="..\/..\/..\/..\/$1index.html"/mg' {} \;

find doctruyen14.vip/truyen-sex-nguoi-lon -type f -name "*.html" -exec perl -0777 -i -pe 's/\.\.\/truyen-sex-nguoi-lon\///mg' {} \;

#find . -type f -name "*.html" -exec perl -0777 -i -pe 's/mage" content="(?:\.\.\/)*((?!http)[^"]+)"/mage" content="https:\/\/baka-bon.github.io\/doctruyen14\/href"/mg' {} \;
