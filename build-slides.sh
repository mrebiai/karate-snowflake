#!/usr/bin/env bash

HTTP_REPO_URL="https://github.com/mrebiai/karate-snowflake"
ASCIIDOCTOR_DOCKER_IMAGE="asciidoctor/docker-asciidoctor:1.91.1"
REVEALJS_DIR="https://cdn.jsdelivr.net/npm/reveal.js@5.1.0"
CONFERENCES=("bdxtestingcommunity:v1" "bordeauxjug:v2")

grep -v '#_slides' README.adoc > index.adoc
sed -i 's|link:abstractv1_fr.adoc.*|'${HTTP_REPO_URL}'/blob/main/abstractv1_fr.adoc[FR^]|' index.adoc
sed -i 's|link:abstractv2_fr.adoc.*|'${HTTP_REPO_URL}'/blob/main/abstractv2_fr.adoc[FR^]|' index.adoc
echo >> index.adoc

rm -rf public
mkdir -p public

for conf in "${CONFERENCES[@]}"
do
  confName="${conf%%:*}"
  confVersion="${conf##*:}"
  sourceCss=$([[ -f "custom-${confName}.css" ]] && echo "custom-${confName}.css" || echo "custom.css")
  CONFERENCE_PNG_BASE64=$(cat images/logo-${confName}.png | base64 -w0) \
  QRCODE_PNG_BASE64=$(cat images/qrcode-slides.png | base64 -w0) \
    envsubst < ${sourceCss} > public/custom-${confName}.css
  docker run --name $(uuidgen) --rm -u $(id -u):$(id -g) -v $(pwd):/documents ${ASCIIDOCTOR_DOCKER_IMAGE} \
    asciidoctor-revealjs -a data-uri -a revealjs_theme=simple \
    -a confName-${confName} -a confname=${confName} \
    -a revealjsdir=${REVEALJS_DIR} -a revealjs_transition=fade \
    -a customcss=custom-${confName}.css -a revealjs_slideNumber=true \
    -D public -o index-${confName}.html \
    presentation${confVersion}_en.adoc
  echo "* link:index-${confName}.html[${confName}^]" >> index.adoc
done

touch public/.nojekyll

docker run --rm --name $(uuidgen) -u $(id -u):$(id -g) -v $(pwd):/documents ${ASCIIDOCTOR_DOCKER_IMAGE} \
  asciidoctor -a data-uri -D public -o index.html index.adoc

rm index.adoc
