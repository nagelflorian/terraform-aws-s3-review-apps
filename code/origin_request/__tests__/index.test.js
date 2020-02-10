const { handler } = require('../index');
const sampleEvent = require('./sample_event.json');

test('it transforms origin request events properly', () => {
  const event = sampleEvent;
  const context = {};
  const cb = jest.fn();

  handler(event, context, cb);
  expect(cb).toHaveBeenCalledWith(null, {
    clientIp: '203.0.113.178',
    headers: {
      'cache-control': [
        { key: 'Cache-Control', value: 'no-cache, cf-no-cache' },
      ],
      host: [{ key: 'Host', value: 'example.org' }],
      'user-agent': [{ key: 'User-Agent', value: 'Amazon CloudFront' }],
      via: [
        {
          key: 'Via',
          value:
            '2.0 8f22423015641505b8c857a37450d6c0.cloudfront.net (CloudFront)',
        },
      ],
      'x-forwarded-for': [{ key: 'X-Forwarded-For', value: '203.0.113.178' }],
      'x-original-host': [
        { key: 'x-original-host', value: 'pr-123.example.com' },
      ],
    },
    method: 'GET',
    origin: {
      s3: {
        authMethod: 'none',
        customHeaders: {},
        domainName: 'example.com.s3.amazonaws.com',
        path: '/pr-123',
      },
    },
    querystring: '',
    uri: '/',
  });
});
