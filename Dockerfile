FROM apache/answer as answer-builder

RUN apk --no-cache add \
    build-base git bash nodejs npm go && \
    npm install -g pnpm

RUN answer build \
    --with github.com/apache/incubator-answer-plugins/connector-basic \
    --with github.com/apache/incubator-answer-plugins/connector-google \
    --with github.com/apache/incubator-answer-plugins/search-algolia \
    --with github.com/apache/incubator-answer-plugins/connector-github \
    --with github.com/apache/incubator-answer-plugins/connector-dingtalk \
    --with github.com/apache/incubator-answer-plugins/editor-formula \
    --with github.com/apache/incubator-answer-plugins/editor-chart \
    --with github.com/apache/incubator-answer-plugins/storage-s3 \
    --with github.com/apache/incubator-answer-plugins/search-meilisearch \
    --output /usr/bin/new_answer

FROM alpine
LABEL maintainer="linkinstar@apache.org"

ARG TIMEZONE
ENV TIMEZONE=${TIMEZONE:-"Asia/Shanghai"}

RUN apk update \
    && apk --no-cache add \
        bash \
        ca-certificates \
        curl \
        dumb-init \
        gettext \
        openssh \
        sqlite \
        gnupg \
        tzdata \
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone

COPY --from=answer-builder /usr/bin/new_answer /usr/bin/answer
COPY --from=answer-builder /data /data
COPY --from=answer-builder /entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

VOLUME /data
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
