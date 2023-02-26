### local build
aws_account_id="<aws_account_id>"
rm -rf ./build
go get github.com/aws/aws-lambda-go/lambda
go mod init main
go mod tidy
CGO_ENABLED=0 go build -o build/mac/main


### lambda build & deploy
# GOOS=linux CGO_ENABLED=0 go build -o build/lambda/main
# find ./build -name lambda -execdir sh -c 'cd lambda && zip -r9 ../lambda.publish.zip ./*' inline-sh {} \;
# aws lambda update-function-code --function-name arn:aws:lambda:eu-west-1:${aws_account_id}:function:InvokerTest --zip-file fileb:///Users/username/src/golang/build/lambda.publish.zip --region eu-west-1 1> /dev/null
# aws lambda wait function-updated --function-name arn:aws:lambda:eu-west-1:${aws_account_id}:function:InvokerTest --region eu-west-1
# aws lambda invoke --function-name arn:aws:lambda:eu-west-1:${aws_account_id}:function:InvokerTest --region eu-west-1 result.json

### fargate build & deploy
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com
docker build -t invoker .
docker tag invoker:latest ${aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com/invoker:latest
docker push ${aws_account_id}.dkr.ecr.eu-west-1.amazonaws.com/invoker:latest
