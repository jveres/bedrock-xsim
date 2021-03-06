# bedrock-xsim
Custom [Bedrock](https://github.com/Expensify/Bedrock) Docker image optimized for size

![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/jveres/bedrock-xsim)

This build includes IPv6 support and statically linked with the following Sqlite extensions:
- Series
- Percentile
- Regexp
- Uuid
- FTS5
- RTree
- Geopoly
- DBStat

## Build Docker image
```sh
docker build -t bedrock
```

## Start Bedrock container
```sh
docker run -v `pwd`/db:/db -p 8888:8888 --env BEDROCK_PARAMS="-db /db/bedrock.db -serverHost 0.0.0.0:8888" bedrock
```

## Test query
```sh
nc localhost 8888
Query: SELECT 1 AS foo, 2 AS bar;

200 OK
commitCount: 8
nodeName: 0b6ce634df5a
peekTime: 422
totalTime: 726
unaccountedTime: 249
Content-Length: 16

foo | bar
1 | 2
```
