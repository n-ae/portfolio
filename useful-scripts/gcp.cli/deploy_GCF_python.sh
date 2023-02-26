#!/bin/sh

function_name="function_name"

# you probably don't need to change these
_bucket_dir="gs://<bucket-dir>"
_project_id="<project-id>"
_region="europe-west1"

# you shouldn't need to change these
__req_file="requirements.txt"
__runtime="python39"
__func_zip="${function_name}.zip"

poetry export -o ${__req_file}
find . -type f -name "*.py" | zip -r9 -@ ${__func_zip} ${__req_file}
gsutil cp ${__func_zip} ${_bucket_dir}
gcloud functions deploy ${function_name} \
    --runtime=${__runtime} \
    --source=${_bucket_dir}/${__func_zip} \
    --region=${_region} \
    --project=${_project_id}
