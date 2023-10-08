#!/bin/sh

dist_dir="dist"
mkdir -p ${dist_dir}/assets

cp manifest.json ${dist_dir}/
cp popup.html ${dist_dir}/
cp assets/* ${dist_dir}/assets/
gopherjs build go/content_script.go -o ${dist_dir}/content_script.js
gopherjs build go/service_worker.go -o ${dist_dir}/service_worker.js
