const { handler } = require("../index");
const sampleEvent = require("./sample_event.json");

describe("viewer requests", () => {
  const authorizedResponse = {
    clientIp: "203.0.113.178",
    headers: {
      accept: [{ key: "accept", value: "*/*" }],
      host: [{ key: "Host", value: "d111111abcdef8.cloudfront.net" }],
      "user-agent": [{ key: "User-Agent", value: "curl/7.66.0" }],
      "x-original-host": [
        { key: "x-original-host", value: "d111111abcdef8.cloudfront.net" },
      ],
    },
    method: "GET",
    querystring: "",
    uri: "/",
  };
  const unauthorizedResponse = {
    body: "Unauthorized",
    headers: {
      "www-authenticate": [
        {
          key: "WWW-Authenticate",
          value: "Basic",
        },
      ],
    },
    status: "401",
    statusDescription: "Unauthorized",
  };

  describe("when basic auth is not enabled", () => {
    it("doesn't challenge for auth", () => {
      const event = sampleEvent;
      const context = {};
      const cb = jest.fn();

      handler(event, context, cb);
      expect(cb).toHaveBeenCalledWith(null, authorizedResponse);
    });
  });

  describe("when basic auth is enabled", () => {
    const OLD_ENV = process.env;
    const username = "jest";
    const password = "jest";

    beforeEach(() => {
      jest.resetModules();
      process.env = {
        ...OLD_ENV,
        BASIC_AUTH_USER_NAME: username,
        BASIC_AUTH_PASSWORD: password,
      }; // Make a copy
    });

    afterAll(() => {
      process.env = OLD_ENV; // Restore old environment
    });

    function appendAuthHeader(event, username, password) {
      const authString =
        "Basic " + Buffer.from(username + ":" + password).toString("base64");
      event.Records[0].cf.request.headers.authorization = [
        {
          value: authString,
        },
      ];
      return { authString, event };
    }

    it("challenges for auth if auth credentials are absent", () => {
      const context = {};

      const cb = jest.fn();
      handler(sampleEvent, context, cb);
      expect(cb).toHaveBeenCalledWith(null, unauthorizedResponse);
    });

    it("challenges for auth if auth credentials are empty", () => {
      const wrongUsername = "";
      const wrongPassword = "";
      const { event } = appendAuthHeader(
        sampleEvent,
        wrongUsername,
        wrongPassword
      );
      const context = {};

      const cb = jest.fn();
      handler(event, context, cb);
      expect(cb).toHaveBeenCalledWith(null, unauthorizedResponse);
    });

    it("challenges for auth if auth credentials are incorrect", () => {
      const wrongUsername = "";
      const wrongPassword = "";
      const { event } = appendAuthHeader(
        sampleEvent,
        wrongUsername,
        wrongPassword
      );
      const context = {};

      const cb = jest.fn();
      handler(event, context, cb);
      expect(cb).toHaveBeenCalledWith(null, unauthorizedResponse);
    });

    it("doesn't challenge for auth if auth credentials are present and correct", () => {
      const { authString, event } = appendAuthHeader(
        sampleEvent,
        username,
        password
      );
      const context = {};

      const cb = jest.fn();
      handler(event, context, cb);
      expect(cb).toHaveBeenCalledWith(null, {
        ...authorizedResponse,
        headers: {
          ...authorizedResponse.headers,
          authorization: [
            {
              value: authString,
            },
          ],
        },
      });
    });
  });
});
