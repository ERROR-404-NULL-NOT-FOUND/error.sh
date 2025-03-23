#!/bin/env bash
./post-builder.sh
./index-builder.sh
./rss-builder.sh
cp -R static robots.txt render/
