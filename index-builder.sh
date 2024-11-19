#!/bin/bash
. ./post-builder.sh
post_list_replace() {
  posts=""
  for i in $1 
  do
    posts="$posts$(convert_post "posts/$i" post-list-template.html)"
  done
  echo "$posts"
}
replace '${POSTS}' "$(post_list_replace "$(head -3 < post-list)")" "$(cat src/index.html)" > render/index.html
replace '${POSTS}' "$(post_list_replace "$(cat post-list)")" "$(cat src/posts.html)" > render/posts.html
