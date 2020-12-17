# bedrock-xsim
Custom [Bedrock](https://github.com/Expensify/Bedrock) DB image optimized for size

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
