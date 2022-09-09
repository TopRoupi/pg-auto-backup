FROM crystallang/crystal:1.5.1-alpine as crystal_dependencies
WORKDIR /shards
COPY shard.* ./
RUN  shards install

FROM crystallang/crystal:1.5.1-alpine as service_build
WORKDIR /sercice_build
COPY . .
COPY --from=crystal_dependencies /shards/lib lib
RUN shards build
RUN mv ./bin/app /usr/local/bin/crservice

FROM crystallang/crystal:1.5.1-alpine as service
WORKDIR /service
COPY --from=service_build /usr/local/bin/crservice crservice

CMD ["./crservice"]
