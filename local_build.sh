#!/bin/bash

# 2020/01/28 - @airman604
# script for locally building OWASP Vancouver web page for testing and debugging
# uses Jekyll Docker image, Docker and `jq` need to be installed
# run in the www-chapter-vancouver directory as it uses files in the current path
# invoke with `-u` or `--update` to update Jekyll image used to the latest version

CONTAINER_NAME=jekyll_local_build

if [ "$1" == "-u" -o "$1" == "--update" ]; then
    echo "Updating Jekyll image"
    docker container rm $CONTAINER_NAME 2>/dev/null
    docker pull jekyll/jekyll
fi

if [ -n "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    # container exists

    # cleanup existing files
    #   grab mount point of the container just in case the script is executed
    #   in a different directory
    OUTPUT_DIR=$(docker container inspect $CONTAINER_NAME | jq -r .[].Mounts[].Source)
    # remove the old output files
    if [ -n "$OUTPUT_DIR" ]; then
        rm -rf "$OUTPUT_DIR/_site/"
    fi

    # re-run the container without re-creating it
    docker start -ai $CONTAINER_NAME
else
    # container doesn't exist, create a new one
    docker run -it --volume="$PWD:/srv/jekyll" --name $CONTAINER_NAME jekyll/jekyll jekyll build
fi
