# ngp-nodejs

This is a sample nodejs application that can be run as a docker container.  
It runs with https://www.npmjs.com/package/restify.

### Steps to run the application

1. ```docker build -t ngp-nodejs .```
2. ```docker run -d -p 9000:9000 ngp-nodejs```

### Health Check

The application returns a ``` { status: 'ok'} ``` at ```localhost:9000/health```


# Notes

These are insfrastructure specific information for the application.

| Question  | Answer |
| ------------- | ------------- |
| Application Ports  | 900  |
| Health check  | `9000/health`  |
| Public Access through ELB  |  True  |
| AWS Log Prefix | `ngp-node-server` | 
| Mandatory Environment Variables |  | 
| Behind API-Gateway | False | 
| Dependent Applications | False | 
| Consumer only | False | 


### App specific environment variables
App specific environment variables can be pass to codepipeliene by specifying environment variables in `.env.sample`.
You will need to add those environment variables in AWS Parameter Store in advance:
```bash
$ aws ssm put-parameter --name ngp-v303-app-stage.XRAY_NAME_NODEJS --value "nodejs" --type SecureString --overwrite
```