FROM nginx:alpine

LABEL org.opencontainers.image.title="my-custom-nginx"
LABEL maintainer="Im-Jongseok"
LABEL description="NGINX 실습 이미지"

ENV APP_ENV=dev PORT=80 APP_NAME=ws

ARG BUILD_VERSION=1.1
LABEL version="${BUILD_VERSION}"

WORKDIR /usr/share/nginx/html

COPY workstation/app/ /usr/share/nginx/html

EXPOSE 80

RUN apk update && \
    apk add --no-cache curl vim bash && \
    rm -rf /var/cache/apk/*

HEALTHCHECK --interval=30s --timeout=5s --retries=3\
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]