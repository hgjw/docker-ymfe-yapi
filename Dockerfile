FROM node:10-alpine as builder

ARG TAG=v1.8.3
ARG REGISTRY=https://registry.npm.taobao.org

RUN apk add --no-cache git python make g++ \
    && git clone --branch $TAG --depth 1 https://github.com/YMFE/yapi.git /vendors \
    && cd /vendors \
    && sed -i -e 's|init\.lock|runtime/init.lock|g' server/install.js \
    && npm install --no-optional --production --registry ${REGISTRY}

RUN npm install -g yapi-cli ykit --registry ${REGISTRY}

RUN npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass/

COPY config.json /

RUN yapi plugin --name yapi-plugin-interface-oauth2-token --registry ${REGISTRY}

FROM node:10-alpine
RUN apk add --no-cache tini

WORKDIR /app/vendors
EXPOSE 3000

COPY --from=builder /vendors /app/vendors
COPY ./entrypoint.sh /app/vendors/

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "/app/vendors/entrypoint.sh" ]
