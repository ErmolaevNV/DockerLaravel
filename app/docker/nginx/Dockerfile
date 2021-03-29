FROM nginx:1.19.8-alpine as base
ARG TZ
ARG USER_ID
ARG GROUP_ID
ENV TZ=${TZ}
RUN apk update && \
    apk add shadow && \
    usermod -u ${USER_ID} nginx && groupmod -g ${GROUP_ID} nginx && \
    apk del shadow && \
    rm -rf /var/cache/apk/*
WORKDIR /app/


COPY ./docker/nginx/default.conf.template /etc/nginx/templates/
WORKDIR /app/

FROM base as develop
COPY . .

FROM base as production
COPY --from=front /app/public/css ./public/css
COPY --from=front /app/public/js ./public/js
COPY ./public/index.php /app/public/index.php
