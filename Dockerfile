FROM crystallang/crystal:1.8.2-alpine as crystal_dependencies
WORKDIR /pg-backup
COPY . .

RUN apk add postgresql15-client
RUN apk add nodejs yarn --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN yarn install
RUN yarn run build

RUN  shards install
RUN shards build

CMD ["./bin/app"]
