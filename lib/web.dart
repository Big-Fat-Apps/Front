import 'dart:convert';

import 'package:http/http.dart' as http;

const String host = '3737-2a00-65e0-6-1100-c481-befc-a940-c7e';

Future<http.Response> apiPost(String method, Map<String, String> params) {
  return http.post(
      Uri.parse('https://$host.eu.ngrok.io/api/$method'),
      headers: {
        'authorization': 'Basic ${base64.encode(utf8.encode('admin:admin'))}',
        'content-type': 'application/json',
        'accept': 'application/json'
      },
      body: jsonEncode(params));
}

Future<http.Response> apiGet(String method) {
  return http.get(
      Uri.parse('https://$host.eu.ngrok.io/api/$method'),
      headers: {
        'authorization': 'Basic ${base64.encode(utf8.encode('admin:admin'))}',
        'content-type': 'application/json',
        'accept': 'application/json'
      }
      );
}
