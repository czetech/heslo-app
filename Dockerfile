FROM cirrusci/flutter:3.0.1 AS build
WORKDIR /build
COPY . ./
RUN flutter build web

FROM alpine:3.16
RUN apk --no-cache add \
    nginx
WORKDIR /app
COPY --from=build /build/build/web ./
COPY docker-nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
