FROM alpine:3.20 AS builder

RUN apk add --no-cache hugo git

WORKDIR /app
COPY . .
RUN hugo --minify

FROM nginx:alpine
COPY --from=builder /app/public /usr/share/nginx/html
EXPOSE 80
