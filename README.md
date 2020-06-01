# ngp-nodejs

This is a sample nodejs application that can be run as a docker container.
It runs with [restify](https://www.npmjs.com/package/restify).

## Steps to run the application

1. ```docker build -t ngp-nodejs .```
1. ```docker run -d -p 9000:9000 ngp-nodejs```

## Health Check

The application returns a ```{ status: 'ok'}``` at ```localhost:9000/health```

### Notes

These are infrastructure specific information for the application.

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

User AWS [parameter store](https://aws.amazon.com/ec2/systems-manager/parameter-store/)

```bash
aws ssm put-parameter --name ngp-v301-dev-stag.XXX --value "XXX" --type SecureString
aws ssm put-parameter --name ngp-v301-dev-stag.YYY --value "YYY" --type SecureString
aws ssm put-parameter --name ngp-v301-dev-stag.ZZZ --value "ZZZ" --type SecureString
```

Place your parameters keys (only keys, not actual secrets) in `.env.sample`:

```bash
➜  ngp-node-server git:(kamol/paramstore) ✗ cat .env.sample
XXX=
ZZZ=
YYY=
```
