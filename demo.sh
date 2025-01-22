#!/usr/bin/env bash

dbt_unit_tests() {
  dbt test
}

dbt_run() {
  dbt run 
}

karate_jar() {
  echo "TODO"
}

karate_docker() {
  docker run --rm \
    -v $(pwd)/burger_factory/it/features:/features \
    -v $(pwd)/burger_factory/it/karate-config.js:/karate-config.js \
    -v $(pwd)/target:/target \
    -v ${SNOWFLAKE_PRIVATE_KEY_PATH}:/${SNOWFLAKE_PRIVATE_KEY_PATH} \
    -v $(pwd)/burger_factory:/burger_factory \
    --env-file ./demo.env \
    -e KARATE_EXTENSIONS=snowflake \
    karate-data:latest features --threads 8
    
  # fix permissions
  docker run --rm \
    -v $(pwd)/target:/reports \
    -v $(pwd)/burger_factory/target:/dbtout \
    busybox chown -R $(id -u):$(id -g) /reports /dbtout
}


$1