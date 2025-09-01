FROM golang:1.25-alpine

RUN go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest

ENTRYPOINT ["oapi-codegen"]
