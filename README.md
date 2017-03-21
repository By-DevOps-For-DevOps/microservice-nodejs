# ngp-nodejs

This is a sample nodejs application that can be run as a docker container. Is is running with https://www.npmjs.com/package/restify.

### Steps to run the application

1. ```docker build -t ngp-nodejs .```
2. ```docker run -d -p 9000:9000 ngp-nodejs```

### Health Check

The application returns a ``` { status: 'ok'} ``` at ```localhost:9000/health```