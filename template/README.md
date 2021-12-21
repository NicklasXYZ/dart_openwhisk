# Running the code locally

The app is built using [Shelf](https://pub.dev/packages/shelf). The app handles HTTP GET and POST requests forwarded from the OpenWhisk platform as POST requests to `/run` containing extra forwarded data that specifies the request method used by the client.

You can test the code locally with the [Dart SDK](https://dart.dev/get-dart) like this:

```bash
dart test

# ... or run the webserver locally with
dart run bin/server.dart
```

Then from a second terminal run:

```bash
### Example GET request
curl -k \
    -d "{
        \"action_name\":\"/guest/demo/test-function\",
        \"action_version\":\"0.0.1\",
        \"activation_id\":\"b6738d98049b467db38d98049ba67d3c\",
        \"deadline\":\"1640003853303\",
        \"namespace\":\"guest\",
        \"transaction_id\":
        \"Rp4ZE4ulxJD9ZZa9jjzZRtvQu84CthHy\",
        \"value\":{
            \"__ow_path\":\"\",
            \"__ow_method\": \"get\",
            \"__ow_headers\": {
                \"accept\":\"*/*\",
                \"content-type\":\"application/json\",
                \"host\":\"owdev-controller.openwhisk.svc.cluster.local:8080\",
                \"user-agent\":\"curl/7.80.0\"
            }
        }
    }" \
    -H "Content-Type: application/json" \
    -X POST localhost:8080/run; \
    echo

# If nothing was changed in the 'template/function/lib/src/function_base.dart' file before 
# deployment then we should just see the default response:
>> Hello from OpenWhisk & Dart!

### Example POST request:
curl -k \
    -d "{
        \"action_name\":\"/guest/demo/test-function\",
        \"action_version\":\"0.0.1\",
        \"activation_id\":\"b6738d98049b467db38d98049ba67d3c\",
        \"deadline\":\"1640003853303\",
        \"namespace\":\"guest\",
        \"transaction_id\":
        \"Rp4ZE4ulxJD9ZZa9jjzZRtvQu84CthHy\",
        \"value\":{
            \"__ow_path\":\"\",
            \"__ow_method\": \"post\",
            \"__ow_headers\": {
                \"accept\":\"*/*\",
                \"content-type\":\"application/json\",
                \"host\":\"owdev-controller.openwhisk.svc.cluster.local:8080\",
                \"user-agent\":\"curl/7.80.0\"
            },
            \"name\": \"Peter\",
            \"age\": \"42\",
            \"height\": \"180.5\"
        }
    }" \
    -H "Content-Type: application/json" \
    -X POST localhost:8080/run; \
    echo

# If nothing was changed in the 'template/function/lib/src/function_base.dart' file before 
# deployment then we should just see the default response:
>> {"body":[{"string_field":"Peter"},{"int_field":42},{"double_field":180.5}]}
```

The data stored under the `"body"` key is essentially be the data that is returned by the OpenWhisk platform to the client. 