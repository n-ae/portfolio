#!/bin/sh

dist_dir="dist"

cp popup.html ${dist_dir}/
cp manifest.json ${dist_dir}/
gopherjs build go/content_script.go -o ${dist_dir}/content_script.js
gopherjs build go/service_worker.go -o ${dist_dir}/service_worker.js
