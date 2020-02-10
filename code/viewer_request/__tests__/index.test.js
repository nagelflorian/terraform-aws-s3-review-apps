const { handler } = require('../index');
const sampleEvent = require('./sample_event.json');

test('it transforms viewer request events properly', () => {
  const event = sampleEvent;
  const context = {};
  const cb = jest.fn();

  handler(event, context, cb);
  expect(cb).toHaveBeenCalledWith(null, {
    clientIp: '203.0.113.178',
    headers: {
      accept: [{ key: 'accept', value: '*/*' }],
      host: [{ key: 'Host', value: 'd111111abcdef8.cloudfront.net' }],
      'user-agent': [{ key: 'User-Agent', value: 'curl/7.66.0' }],
      'x-original-host': [
        { key: 'x-original-host', value: 'd111111abcdef8.cloudfront.net' },
      ],
    },
    method: 'GET',
    querystring: '',
    uri: '/',
  });
});
