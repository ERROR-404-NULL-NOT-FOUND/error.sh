#!/usr/local/bin/bash
. ./post-builder.sh
post_builder
./index-builder.sh
./rss-builder.sh
cp -R static robots.txt render/
