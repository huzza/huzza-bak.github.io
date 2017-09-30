#!/bin/bash

find . -name "*.md" | while read md_file
do
	echo "start to compile ${md_file} ... "
	html_file=$(echo ${md_file} | sed 's/md$/html/g')
	showdown makehtml -i ${md_file} -o ${html_file}
done
