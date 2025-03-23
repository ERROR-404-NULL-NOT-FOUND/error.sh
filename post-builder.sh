#!/bin/env bash
replace () {
  pattern="${1}"
  replace="${2}"
  echo "${3}" | \
    while read -r line
  do
    echo "${line//${pattern}/${replace}}"
  done  
}

select_content () {
  local pattern_start="${1}"
  local pattern_end="${2}"
  local buff_add=0
  echo "${3}" | \
    while read -r line
  do
    if [ ${buff_add} -eq 1 ] && [ "${line}" != "${pattern_end}" ]; then
      echo "${line}"
    fi
    if [ "${line}" == "${1}" ]; then
      buff_add=1
    elif [ "${line}" == "${2}" ]; then 
      buff_add=0
    fi
  done
}

replace_content () {
  local pattern_start="${1}"
  local pattern_end="${2}"
  local replacement="${4}"
  local buff_add=0
  echo "${3}" | \
    while read -r line
  do
    if [ "${line}" == "${1}" ]; then
      buff_add=1
    elif [ "${line}" == "${2}" ]; then 
      buff_add=0
      echo "${replacement}"
    fi
    if [ ${buff_add} -eq 0 ] && [ "${line}" != "${pattern_end}" ]; then
      echo "${line}"
    fi
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
  template=$(render_post "${template}")
  echo "${template}"
}
print_top () {
  for i in $(seq 1 81); do
    echo -n "-"
  done
  echo
}
make_box () {
  text="${1}"
  class="${2}"
  echo "<pre class=textbox><span class="${class}">$(print_top)</span>"
  echo "$(echo $class | tr '[:lower:]' '[:upper:]'):
${text}" | \
    while read -r line; do
    echo -n "<span class=${class}>|</span><span>${line}"
    for i in $(seq 1 $((80-$(echo "${line}" | wc -m)))); do
      echo -n " "
    done
    echo "</span><span class=${class}>|</span>"
  done
  echo "<span class="${class}">$(print_top)</span></pre>"
}
render_post () {
  post_text="$(echo "${1}" | fold -w 80 -s)"
  warning="$(select_content "[WARN]" "[/WARN]" "${post_text}")"
  info="$(select_content "[NOTE]" "[/NOTE]" "${post_text}")"
  post_text="$(replace_content "[WARN]" "[/WARN]" "${post_text}" "$(make_box "${warning}" warn)")"
  post_text="$(replace_content "[NOTE]" "[/NOTE]" "${post_text}" "$(make_box "${info}" info)")"
  echo "${post_text}"
}

rm -rf render
mkdir -p render/posts
mkdir -p render/random
for i in $(find ./src/{posts,random}/ | sed "s/\.\/src\///g" | grep "\.html") #just list the files
do
  echo "$i"
  convert_post "$i" "html/post-template.html" 1 > "render/$i"
  #render_post "$(cat ./src/$i)"
done
