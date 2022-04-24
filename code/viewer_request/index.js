const HEADER_NAME = "x-original-host";

exports.handler = (event, _, callback) => {
  const request = event.Records[0].cf.request;
  const host = request.headers["host"][0].value;

  request.headers[HEADER_NAME] = [
    {
      key: HEADER_NAME,
      value: host,
    },
  ];

  const BASIC_AUTH_USER_NAME = process.env.BASIC_AUTH_USER_NAME;
  const BASIC_AUTH_PASSWORD = process.env.BASIC_AUTH_PASSWORD;
  const isUsingBasicAuth = !!BASIC_AUTH_USER_NAME && !!BASIC_AUTH_PASSWORD;

  if (isUsingBasicAuth) {
    const headers = request.headers;
    const expectedAuthString =
      "Basic " +
      new Buffer(BASIC_AUTH_USER_NAME + ":" + BASIC_AUTH_PASSWORD).toString(
        "base64"
      );

    // Challenge for auth if auth credentials are absent or incorrect
    if (
      typeof headers.authorization == "undefined" ||
      headers.authorization[0].value != expectedAuthString
    ) {
      const response = {
        status: "401",
        statusDescription: "Unauthorized",
        body: "Unauthorized",
        headers: {
          "www-authenticate": [{ key: "WWW-Authenticate", value: "Basic" }],
        },
      };
      callback(null, response);
    }
  }

  callback(null, request);
};
