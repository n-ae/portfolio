aws logs create-export-task \
    --log-group-name "my-log-group-name" \
    --destination "bucket-name" \
    --from 1676332800000 \
    --to 1676419200000 \
    --log-stream-name "my-log-stream-name" \
    --region ap-east-1
