#!/usr/bin/env bash

HTTP_REPO_URL="https://github.com/mrebiai/karate-snowflake"
ASCIIDOCTOR_DOCKER_IMAGE="asciidoctor/docker-asciidoctor:1.81.0"
REVEALJS_DIR="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0"
CONFERENCES=("bdxtestingcommunity")

cat README.adoc > index.adoc
sed -i 's|link:abstract_fr.adoc.*|'${HTTP_REPO_URL}'/blob/main/abstract_fr.adoc[FR^]|' index.adoc
echo -e "\n== Slides\n" >> index.adoc

rm -rf public
mkdir -p public

for conf in "${CONFERENCES[@]}"
do
  sourceCss=$([[ -f "custom-${conf}.css" ]] && echo "custom-${conf}.css" || echo "custom.css")
  CONFERENCE_PNG_BASE64=$(cat images/logo-${conf}.png | base64 -w0) \
  QRCODE_PNG_BASE64=$(cat images/qrcode-slides.png | base64 -w0) \
    envsubst < ${sourceCss} > public/custom-${conf}.css
  docker run --name $(uuidgen) --rm -u $(id -u):$(id -g) -v $(pwd):/documents ${ASCIIDOCTOR_DOCKER_IMAGE} \
    asciidoctor-revealjs -a data-uri -a revealjs_theme=simple \
    -a conf-${conf} -a confname=${conf} \
    -a revealjsdir=${REVEALJS_DIR} -a revealjs_transition=fade \
    -a customcss=custom-${conf}.css -a revealjs_slideNumber=true \
    -D public -o index-${conf}.html \
    presentation_en.adoc
  echo "* link:index-${conf}.html[${conf}^]" >> index.adoc
done

touch public/.nojekyll

docker run --rm --name $(uuidgen) -u $(id -u):$(id -g) -v $(pwd):/documents ${ASCIIDOCTOR_DOCKER_IMAGE} \
  asciidoctor -a data-uri -D public -o index.html index.adoc

rm index.adoc