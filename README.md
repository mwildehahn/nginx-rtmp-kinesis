# nginx-rtmp-kinesis

Example of using nginx-rtmp to stream to AWS kinesis

To run, build the container:

```
docker build -t nginx-rtmp-kinesis .
```

Run the container, specifying your AWS credentials as environment variables:

```
docker run -e "AWS_ACCESS_KEY=<access key>" -e "AWS_SECRET_KEY=<secret key>" -e "AWS_REGION=<region>" -p 1935:1935 -p 8080:8080 -v "$(pwd)"/debug:/opt/debug --privileged nginx-rtmp-kinesis
```

Once the container is running, you can start a stream from OBS https://obsproject.com/ to `rtmp://127.0.0.1/stream` specifying an arbitrary stream key. Logs for the process are available if you exec into the container and view `/tmp/stream-<stream-key>.log`.
