FROM golang:1.26.2-alpine AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
COPY internal ./internal

RUN CGO_ENABLED=0 GOOS=linux go build -o fitbyte .

FROM alpine:3.22

WORKDIR /app

ENV PORT=:8080
ENV FILEPATH_ROOT=web

COPY --from=build /app/fitbyte ./fitbyte
COPY web ./web

RUN touch .env

EXPOSE 8080

CMD ["./fitbyte"]