FROM golang:1.13.3-alpine as build

RUN apk add --no-cache git openssh-client gcc musl-dev

WORKDIR /go/src/querier

COPY . .

RUN go build


FROM alpine

COPY --from=build /go/src/querier/querier querier

CMD ["./querier"]
