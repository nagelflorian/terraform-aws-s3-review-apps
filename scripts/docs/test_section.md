## Tests

You can run automated end-to-end tests using the following command, notice this will deploy actual resources in your AWS account which might result in charges for you:

```console
DOMAIN_NAME="foo" ROUTE_53_ROUTE_ID="bar" go test -v -count=1 -mod=vendor -timeout=1800s ./...
```
