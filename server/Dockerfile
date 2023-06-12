FROM golang:1.20.5-bullseye

ENV APP_NAME furry-nebula
ENV APP_HOME /app/${APP_NAME}
WORKDIR "$APP_HOME"

COPY . .

RUN go mod tidy
RUN go build -v -o "$APP_NAME"

CMD "./$APP_NAME"