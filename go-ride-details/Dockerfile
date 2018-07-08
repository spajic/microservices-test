# iron/go:dev is the alpine image with the go tools added
FROM iron/go:dev
WORKDIR /app
ENV SRC_DIR=/go/src/github.com/spajic/microservices-test/go-ride-details
ADD . $SRC_DIR
RUN cd $SRC_DIR; go build -o app; cp app /app/
ENTRYPOINT ["./app"]
