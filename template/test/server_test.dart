import 'dart:convert';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  final port = '8081';
  final host = 'http://0.0.0.0:$port';

  setUp(() async {
    await TestProcess.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );
  });

  // Create some dummy data similar to the data that is forwarded by the 
  // OpenWhisk platform to our service that will eventually process the
  // data
  final Map<String, dynamic> defaultBody = {
    "action_name": "/guest/demo/test-function",
    "action_version": "0.0.1",
    "activation_id":"b6738d98049b467db38d98049ba67d3c",
    "deadline":"1640003853303",
    "namespace":"guest",
    "transaction_id":"Rp4ZE4ulxJD9ZZa9jjzZRtvQu84CthHy",
    "value":
    {
      // The OpenWhisk platform makes the request method used by the 
      // client available under the following '__ow_method' key.
      // Set to empty for now, so it can be filled out later...
      "__ow_method": "",
      "__ow_headers":
      {
          "accept":"*/*",
          "content-type":"application/json",
          "host":"owdev-controller.openwhisk.svc.cluster.local:8080",
          "user-agent":"curl/7.80.0"
      },
      "__ow_path":""
    },
  };

  // Test expected OpenWhisk environment initialization response
  test('Initalization', () async {
    final response = await post(Uri.parse(host + '/init'));
    expect(response.statusCode, 200);
    expect(response.body, 'Everything is fine!');
  });

  test('Run: Get request success', () async {
    // Create a copy of the default request body so it can be modified
    Map<String, dynamic> body = {...defaultBody};

    // Set the request method that is being tested through the OpenWhisk 
    // platform 
    body['value']['__ow_method'] = 'get';

    final response = await post(
        Uri.parse(host + '/run'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    expect(response.statusCode, 200);
  });

  test('Run: Post request success', () async {
    // Create a copy of the default request body so it can be modified
    Map<String, dynamic> body = {...defaultBody};

    // Set the request method that is being tested through the OpenWhisk 
    // platform 
    body['value']['__ow_method'] = 'post';

    // Add some additional data that is provided by a client sending a POST
    // request to the OpenWhisk platform. The OpenWhisk platform 
    // subsequently forwards the data so it can be handled by our service  
    body['value']['name'] = 'Peter';
    body['value']['height'] = '180.5';
    body['value']['age'] = '42';

    final response = await post(
        Uri.parse(host + '/run'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    expect(response.statusCode, 200);

    dynamic responseBody = jsonDecode(response.body);

    // Expect a response containing the data given in a POST request, but 
    // reorganized by type and provided in individual Maps in a List
    expect(responseBody['body'], [
        {'string_field': 'Peter'},
        {'int_field': 42},
        {'double_field': 180.5},
    ]);
  });

  test('Run: Patch request failure (not yet implemented)', () async {
    // Create a copy of the default request body so it can be modified
    Map<String, dynamic> body = {...defaultBody};

    // Set the request method that is being tested through the OpenWhisk 
    // platform 
    body['value']['__ow_method'] = 'patch';

    final response = await post(
        Uri.parse(host + '/run'),
        headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    expect(response.statusCode, 405);
  });
}
