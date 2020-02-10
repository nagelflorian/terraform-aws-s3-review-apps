const HEADER_NAME = 'x-original-host';

exports.handler = (event, _, callback) => {
  const request = event.Records[0].cf.request;

  const originalHost = request.headers[HEADER_NAME][0].value;
  const labels = originalHost.split('.');

  // Use left-most label to build S3 path.
  const path = `/${labels[0]}`;
  request.origin.s3.path = path;

  callback(null, request);
};
