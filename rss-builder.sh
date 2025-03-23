#!/bin/env bash
. ./post-builder.sh
post_list_replace() {
  posts=""
  for i in $1 
  do
    posts="$posts$(convert_post "posts/$i" rss/post-list-template.xml)"
  done
  echo "$posts"
}
replace '${POSTS}' "$(post_list_replace "$(cat post-list)")" "$(cat src/rss.xml)" > render/rss.xml
replace '${TIME}' "$(TZ=GMT date +"%Y-%m-%dT%H:%M:%SZ")" "$(cat render/rss.xml)" > render/rss.xml
