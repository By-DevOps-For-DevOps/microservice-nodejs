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
App specific environment variables can be pass to codepipeliene by specifying the s3 bucket and file name which contain the environment variables.
- First line should be a newline
- Variables should be in key value format
- Keep the tab spaces same as example file
Eg:
```
        
        Environment:
        - Name: NODE_ENV
          Value: 6.0
```

[Example file](./code_build_env.yaml)
