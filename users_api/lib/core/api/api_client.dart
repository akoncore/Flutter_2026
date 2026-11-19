import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// The only place that talks to the network. Everything that goes wrong is
/// turned into an [ApiException] here, so nobody above has to know about
/// SocketException, status codes or FormatException.
class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  /// Headers in one place.
  Map<String, String> get _headers => const {'Accept': 'application/json'};

  /// Addresses are built with Uri.https, never by string concatenation.
  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.https(host, path, query);

  Future<http.Response> get(Uri uri) => _request(
        () => _client.get(uri, headers: _headers),
      );

  Future<http.Response> post(Uri uri, Object body) => _request(
        () => _client.post(
          uri,
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      );

  Future<http.Response> _request(Future<http.Response> Function() call) async {
    final r = await _send(call);
    _check(r); // status first, body second - always
    return r;
  }

  /// Pile 1: no response at all.
  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log('${r.request?.method} ${r.request?.url} -> ${r.statusCode}',
            name: 'api');
      }
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  /// Pile 2: the server answered, but with an error status.
  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
  }

  /// Pile 3: the body is not JSON.
  dynamic decode(http.Response r) {
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: ${e.message}');
    }
  }
}
