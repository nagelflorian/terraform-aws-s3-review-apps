const HEADER_NAME = 'x-original-host';

exports.handler = (event, _, callback) => {
  const request = event.Records[0].cf.request;
  const host = request.headers['host'][0].value;

  request.headers[HEADER_NAME] = [
    {
      key: HEADER_NAME,
      value: host,
    },
  ];

  callback(null, request);
};
