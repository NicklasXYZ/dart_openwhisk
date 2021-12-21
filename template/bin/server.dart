import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:function/function.dart' as svc;

// Run the shelf server and host a [Service] instance on port 8080
void main() async {
  // Use any available host or container IP (usually `0.0.0.0`)
  final ip = InternetAddress.anyIPv4;
  // For running in containers, we respect the PORT environment variable
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final _pipeline = svc.getPipeline();
  final server = await shelf_io.serve(_pipeline, ip, port);
  print('Server running on address: ${ip.address}:$port');
}
