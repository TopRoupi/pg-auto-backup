FROM crystallang/crystal:1.8.2-alpine as crystal_dependencies
WORKDIR /shards
COPY shard.* ./
RUN  shards install

FROM crystallang/crystal:1.8.2-alpine as service_build
WORKDIR /service_build
COPY . .
COPY --from=crystal_dependencies /shards/lib lib
RUN shards build
RUN mv ./bin/app /usr/local/bin/crservice

FROM crystallang/crystal:1.8.2-alpine as service
WORKDIR /service
COPY --from=service_build /usr/local/bin/crservice crservice

RUN apk add --no-cache postgresql15-client

CMD ["./crservice"]
