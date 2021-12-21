import 'dart:async' show Future;
import 'dart:convert';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';


getPipeline() {
  // NOTE: Database connections and whatnot should be initialized here and
  // passed to whatever service that needs it

  // Create a service to handle incoming requests
  final service = Service();

  // Configure a pipeline that logs incoming requests
  final pipeline =
      Pipeline().addMiddleware(logRequests()).addHandler(service.handler);
    return pipeline;
}

class Service {
  Handler get handler {
    // Create a 'Router' object for handling URL routing
    final router = Router();

    // (REQUIRED) This function performs function environment initialization.
    // The function is run when a POST request is sent to localhost:8080/init
    // by the OpenWhisk platform
    router.post('/init', (Request request) async {
      return Response.ok('Everything is fine!');
    });

    // (REQUIRED) This is where the serverless function invocation happens. 
    // This function is run when a POST request is sent to localhost:8080/run
    // by the OpenWhisk platform 
    router.post('/run', (Request request) async {

      // Decode the received JSON data forwarded by the OpenWhisk platform 
      dynamic reqData = jsonDecode(await request.readAsString());

      // Retrieve the specific data that was sent by a client and subsequently 
      // forwarded by the OpenWhisk platform 
      dynamic data = reqData['value'] ?? null;

      // Pass on the data to create an appropriate response for the client to 
      // receive
      return await handleRequest(data);
    });

   return router;
  }
}

// NOTE: THE FUNCTIONS CALLED BELOW THIS POINT ARE FOR ILLUSTRATIONAL AND 
// TESTING PURPOSES ONLY. YOU SHOULD ADD/IMPLEMENT YOUR OWN FUNCTION LOGIC 
// AND CALL THE FUNCTIONS HERE BELOW!
Future<Response> handleRequest(Map<String, dynamic> data) async {

  // If the OpenWhisk platform has forwarded the data sent by the client 
  // successfully then continue
  if (data != null) {
    // Determine the request method used by the client. The OpenWhisk platform
    // makes this information available under key '__ow_method'
    String reqMethod = data['__ow_method'] ?? null;
  
    // If the client sent a GET request then call the 'getTestData' function
    if (reqMethod == 'get') {
      return await getTestData();
    }
    // If the client sent a POST request then call the 'postTestData' function
    else if (reqMethod == 'post') {
      return await postTestData(data);
    }
    // Otherwise the client sent an invalid request 
    else {
      // Return: Method not allowed
      return Response(405, body: "Invalid request method used!");
    }
  }
  // Otherwise something went wrong as the OpenWhisk platform did not forward
  // the appropriate data
  else {
      // Return: Internal server error
      return Response.internalServerError();
  }
}

// Function called on a client GET request
Future<Response> getTestData() async {
  Map<String, String> returnData = {
    'body': "Hello from Dart & OpenWhisk!"
  };
  return Response.ok(jsonEncode(returnData));
}

// Function called on a client POST request
Future<Response> postTestData(Map<String, dynamic> data) async {

  // For illustrational purposes simply reorganize the received data
  Map<String, List<Map<String, dynamic>>> returnData = {
    'body': [
      {'string_field': data['name'] ?? ""},
      {'int_field': int.tryParse(data['age'] ?? "-1")},
      {'double_field': double.tryParse(data['height'] ?? "-1.0")}
    ]
  };

  // Encode the reorganized JSON data and return it
  var jsonText = jsonEncode(returnData);
  return Response.ok(jsonText);
}
