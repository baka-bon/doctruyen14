#!/bin/bash

#find . -type f -name "*.html" -exec dos2unix {} \;

# find . -type f -name "*.html" -mindepth 2 -maxdepth 2 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.biz\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|tag\/(?:doc-truyen-cuoi|doc-truyen-tranh|gay-18|gay-dam|gay-du-dit-dam|gay-sex|gaysex|loan-luan-gay|sex-gay|sex-gayy-dam|truyen-gay|truyen-gay-18|truyen-gay-hay-2|truyen-gay-loan-luan|truyen-gay-ngan|truyen-sex-gay-2|truyen-teen-2)\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/)|audio-truyen-gay\/(?<!feed\/))?"/href="$1index.html"/mg' {} \;
# find . -type f -name "*.html" -mindepth 3 -maxdepth 3 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.biz\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|tag\/(?:doc-truyen-cuoi|doc-truyen-tranh|gay-18|gay-dam|gay-du-dit-dam|gay-sex|gaysex|loan-luan-gay|sex-gay|sex-gayy-dam|truyen-gay|truyen-gay-18|truyen-gay-hay-2|truyen-gay-loan-luan|truyen-gay-ngan|truyen-sex-gay-2|truyen-teen-2)\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/)|audio-truyen-gay\/(?<!feed\/))?"/href="..\/$1index.html"/mg' {} \;
# find . -type f -name "*.html" -mindepth 4 -maxdepth 4 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.biz\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|tag\/(?:doc-truyen-cuoi|doc-truyen-tranh|gay-18|gay-dam|gay-du-dit-dam|gay-sex|gaysex|loan-luan-gay|sex-gay|sex-gayy-dam|truyen-gay|truyen-gay-18|truyen-gay-hay-2|truyen-gay-loan-luan|truyen-gay-ngan|truyen-sex-gay-2|truyen-teen-2)\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/)|audio-truyen-gay\/(?<!feed\/))?"/href="..\/..\/$1index.html"/mg' {} \;
# find . -type f -name "*.html" -mindepth 5 -maxdepth 5 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.biz\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|tag\/(?:doc-truyen-cuoi|doc-truyen-tranh|gay-18|gay-dam|gay-du-dit-dam|gay-sex|gaysex|loan-luan-gay|sex-gay|sex-gayy-dam|truyen-gay|truyen-gay-18|truyen-gay-hay-2|truyen-gay-loan-luan|truyen-gay-ngan|truyen-sex-gay-2|truyen-teen-2)\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/)|audio-truyen-gay\/(?<!feed\/))?"/href="..\/..\/..\/$1index.html"/mg' {} \;
# find . -type f -name "*.html" -mindepth 6 -maxdepth 6 -exec perl -0777 -i -pe 's/href="https:\/\/doctruyen14\.biz\/((?!feed\/|comments\/|wp-json\/|truyen-ma\/|truyen-cuoi\/|dang-truyen\/|nghe-audio-truyen-sex-mp3\/|truyen-gay\/|truyen-teen\/|truyen-tinh-cam\/|truyen-tranh\/|tag\/(?:doc-truyen-cuoi|doc-truyen-tranh|gay-18|gay-dam|gay-du-dit-dam|gay-sex|gaysex|loan-luan-gay|sex-gay|sex-gayy-dam|truyen-gay|truyen-gay-18|truyen-gay-hay-2|truyen-gay-loan-luan|truyen-gay-ngan|truyen-sex-gay-2|truyen-teen-2)\/|(?:tag\/)?(?:audio-truyen|truyen-audio))[^"]+\/(?<!feed\/)|audio-truyen-gay\/(?<!feed\/))?"/href="..\/..\/..\/..\/$1index.html"/mg' {} \;

set -euo pipefail
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
git config core.quotepath false

# REQUIREMENTS:
#   brew install gawk
#   macOS xargs (supports -0)

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# 1️⃣ Collect staged, unstaged, and untracked files
{
  git diff --name-only --cached
  git diff --name-only
  git ls-files -o --exclude-standard
} \
| sort -u \
| awk -F'/' 'NF >= 2 && /\.html$/ { print NF "\t" $0 }' \
| sort -n \
| awk -F'\t' '
    {
      depth = $1
      file  = $2
      print file >> ("'"$tmpdir"'/depth_" depth ".list")
    }
'

# 2️⃣ Batch-process per depth
for f in "$tmpdir"/depth_*.list; do
  [ -s "$f" ] || continue   # skip if file does not exist or is empty

  depth="${f##*/depth_}"
  depth="${depth%.list}"

  file_count=$(wc -l < "$f" | tr -d ' ')

  if [ "$file_count" -eq 0 ]; then
    echo "Skipping depth=$depth (0 files)"
    continue
  fi

  up=""
  for ((i=0;i<depth-2;i++)); do up+="../"; done

  echo "Processing depth=$depth (${file_count} file(s), ../ x $((depth-2)))"

  xargs -n 100 \
    perl -0777 -i -pe \
    "s#href=\"https://doctruyen14\.biz/((?!feed/|comments/|wp-json/|truyen-ma/|truyen-cuoi/|dang-truyen/|nghe-audio-truyen-sex-mp3/|truyen-gay/|truyen-teen/|truyen-tinh-cam/|truyen-tranh/|tag/(?:doc-truyen-cuoi|doc-truyen-tranh|gay-18|gay-dam|gay-du-dit-dam|gay-sex|gaysex|loan-luan-gay|sex-gay|sex-gayy-dam|truyen-gay|truyen-gay-18|truyen-gay-hay-2|truyen-gay-loan-luan|truyen-gay-ngan|truyen-sex-gay-2|truyen-teen-2)/|(?:tag/)?(?:audio-truyen|truyen-audio))[^\"]+/(?<!feed/)|audio-truyen-gay/(?<!feed/))?\"#href=\"${up}\$1index.html\"#mg" \
    < "$f"
done

#find doctruyen14.biz/truyen-sex-nguoi-lon -type f -name "*.html" -exec perl -0777 -i -pe 's/\.\.\/truyen-sex-nguoi-lon\///mg' {} \;

#find . -type f -name "*.html" -exec perl -0777 -i -pe 's/mage" content="(?:\.\.\/)*((?!http)[^"]+)"/mage" content="https:\/\/baka-bon.github.io\/doctruyen14\/href"/mg' {} \;

git add -u doctruyen14.biz
