library jaguar_mux.example.simple.client;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const String kHostname = 'localhost';

const int kPort = 8080;

final http.Client _client = new http.Client();

Future<Null> printHttpClientResponse(http.Response resp) async {
  print('=========================');
  print("body:");
  print(resp.body);
  print("statusCode:");
  print(resp.statusCode);
  print("headers:");
  print(resp.headers);
  print('=========================');
}

Future<Null> execNone_notCors() async {
  String url = "http://$kHostname:$kPort/none";
  http.Response resp = await _client.get(url);

  await printHttpClientResponse(resp);
}

Future<Null> execNone_cors() async {
  String url = "http://$kHostname:$kPort/none";
  http.Response resp =
      await _client.get(url, headers: {'Origin': 'http://example.com:8000'});

  await printHttpClientResponse(resp);
}

Future<Null> execOrigin_match() async {
  String url = "http://$kHostname:$kPort/origins";
  http.Response resp =
      await _client.get(url, headers: {'Origin': 'http://example.com'});

  await printHttpClientResponse(resp);
}

Future<Null> execOrigin_notMatch() async {
  String url = "http://$kHostname:$kPort/origins";
  http.Response resp =
      await _client.get(url, headers: {'Origin': 'http://google.com'});

  await printHttpClientResponse(resp);
}

Future<Null> execPreflight() async {
  final req = new http.Request(
      'OPTIONS', new Uri.http('$kHostname:$kPort', '/preflight'));
  req.headers['Origin'] = 'http://example.com';
  req.headers['Access-Control-Request-Method'] = 'GET';
  http.Response resp = await http.Response.fromStream(await _client.send(req));

  await printHttpClientResponse(resp);
}

main() async {
  await execNone_notCors();
  await execNone_cors();

  await execOrigin_match();
  await execOrigin_notMatch();

  await execPreflight();

  exit(0);
}
