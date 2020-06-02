var AWSXRayRestify = require('aws-xray-sdk-restify');
var restify = require('restify');

const response = {
    status: 'ok'
}
var server = restify.createServer();

AWSXRayRestify.enable(server, process.env.XRAY_NAME_NODEJS || 'nodejs');
server.get('/health', function (req, res, next) {
  res.send(response);
  return next();
});

server.listen(9000, function() {
  console.log('%s listening at %s', server.name, server.url);
});