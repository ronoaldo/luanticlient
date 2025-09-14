#!/bin/bash

VERSIONS="5.8.0 5.9.0 5.9.1 5.10.0 5.11.0 5.12.0 5.13.0 master"

for VERSION in $VERSIONS ; do
    echo "=== RUN Testing build for $VERSION"
    VERSION=${VERSION} ./scripts/docker-run.sh scripts/buildappimage.sh 2>&1 > /tmp/build-${VERSION}.log
    if [ $? -eq 0 ] ; then
        echo "--- PASS"
    else
        echo "--- FAIL"
    fi
done
