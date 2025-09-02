FROM golang:1.25 AS build

RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

RUN go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest

RUN git config --global --add safe.directory /app

RUN npm install -g @asyncapi/cli @asyncapi/generator @asyncapi/go-watermill-template

ENTRYPOINT [ "sh", "-c" ]
