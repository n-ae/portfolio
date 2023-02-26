
ARG PUBLISH_FOLDER="/out"

FROM golang:alpine as builder
ARG PUBLISH_FOLDER
RUN mkdir /home/app
WORKDIR /home/app
COPY ./main.go .
RUN go get github.com/aws/aws-lambda-go/lambda
RUN go mod init main
RUN go mod tidy
RUN go build -o ${PUBLISH_FOLDER}/main

FROM alpine
ARG PUBLISH_FOLDER
# configured on ecs task definition with nofile option
# RUN ulimit -n 1024
COPY --from=builder ${PUBLISH_FOLDER} .
ENV RPS="200"
ENV RESTAURANT_COUNT="170"
ENV DURATION="2"
ENTRYPOINT ./main
