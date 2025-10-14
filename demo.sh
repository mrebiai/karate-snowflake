#!/usr/bin/env bash

KARATE_CONNECT_VERSION=0.5.1
NB_THREADS=8
DBT_PROJECT="burger_factory"
IT_PATH="${DBT_PROJECT}/it"
REPORTS_DIR="karate-reports-batching"

if [[ ! -d py_venv ]]; then
  source .envrc
fi

dbt_unit_tests() {
  dbt test
}

dbt_run() {
  dbt run 
}

karate_jar() {
  if [[ ! -f karate-connect-${KARATE_CONNECT_VERSION}-standalone.jar ]]; then
    curl -O -L "https://github.com/lectra-tech/karate-connect/releases/download/v${KARATE_CONNECT_VERSION}/karate-connect-${KARATE_CONNECT_VERSION}-standalone.jar"
  fi
  fixRights
  # tag::karate_jar[]
  java -Dextensions=snowflake,dbt -jar karate-connect-${KARATE_CONNECT_VERSION}-standalone.jar \
    ${IT_PATH}/features --clean --configdir ${IT_PATH} --reportdir target/${REPORTS_DIR} --threads ${NB_THREADS}
  # end::karate_jar[]
  fixRights
}

karate_docker() {
  # tag::karate_docker[]
  docker run --rm \
    -v $(pwd)/${IT_PATH}:/${IT_PATH} \
    -v $(pwd)/target:/target \
    -v ${SNOWFLAKE_PRIVATE_KEY_PATH}:${SNOWFLAKE_PRIVATE_KEY_PATH} \
    -v $(pwd)/${DBT_PROJECT}:/${DBT_PROJECT} \
    --env-file ./demo.env -e KARATE_EXTENSIONS=snowflake,dbt \
    lectratech/karate-connect:${KARATE_CONNECT_VERSION} \
      ${IT_PATH}/features --clean --configdir ${IT_PATH} --reportdir target/${REPORTS_DIR} --threads ${NB_THREADS}
  # end::karate_docker[]

  fixRights
}
  

fixRights() {
  docker run --rm \
    -v $(pwd)/target:/reports \
    -v $(pwd)/burger_factory/target:/dbtout \
    -v $(pwd)/burger_factory/logs:/dbtlogs \
    busybox chown -R $(id -u):$(id -g) /reports /dbtout /dbtlogs
}

$1