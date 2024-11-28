#!/usr/local/bin/bash 
replace () {
  pattern="${1}"
  replace="${2}"
  echo "${3}" | \
    while read -r line
  do
    echo "${line//${pattern}/${replace}}"
  done  
}

convert_post () {
  post_text=$(cat "./src/${1}")
  author=$(cat "./static/templates/html/author.html")
  footer=$(cat "./static/templates/html/footer.html")
  template=$(cat "./static/templates/${2}")

  title=$(echo "${post_text}" | head -1) #assume the title is one line
  desc=$(echo "${post_text}" | head -2 | tail -1) #ditto
  date=$(echo "${post_text}" | head -3 | tail -1) #ditto
  wc=$(echo "${post_text}"   | wc -w)
  
  path="${1}"
  
  if [ $3 ]; then
    template=$(replace '${AUTHOR}'         "${author}"       "${template}")
    template=$(replace '${FOOTER}'         "${footer}"       "${template}")
  fi
  template=$(replace '${TITLE}'          "${title}"        "${template}")
  template=$(replace '${DESC}'           "${desc}"         "${template}")
  template=$(replace '${DATE}'           "${date}"         "${template}")
  template=$(replace '${PATH}'           "${path}"         "${template}")
  template=$(replace '${WC}'           	 "${wc}"         "${template}")

  if [ $3 ]; then
    #post_text=$(echo "${doc_text}" | sed -e "s/\(https\:\/\/[^ ]*\)/<a href='\1'>\1<\/a>/g")
    post_text=$(echo "${post_text}"         | tail -$(($(echo "${post_text}" | wc -l) - 3))) # remove the title and desc, as they're in the template
  
    template=$(replace '${CONTENT}'        "${post_text}"    "${template}")
  fi

  echo "${template}"
}
post_builder () {
rm -rf render
mkdir -p render/posts
mkdir -p render/random
for i in $(find ./src/{posts,random}/ | sed "s/\.\/src\///g" | grep "\.html") #just list the files
do
  echo "$i"
  convert_post "$i" "html/post-template.html" 1 > "render/$i"
done
}
