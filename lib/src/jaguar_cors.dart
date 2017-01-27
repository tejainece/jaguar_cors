// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library jaguar_cors;

import 'package:jaguar/jaguar.dart';

part 'filter.dart';
part 'options.dart';

class CorsHeaders {
  static const String AllowedOrigin = 'Access-Control-Allow-Origin';

  static const String AllowCredentials = 'Access-Control-Allow-Credentials';

  static const String Vary = 'Vary';

  static const String AllowedMethods = 'Access-Control-Allow-Methods';

  static const String AllowedHeaders = 'Access-Control-Allow-Headers';

  static const String MaxAge = 'Access-Control-Max-Age';

  static const String ExposeHeaders = 'Access-Control-Expose-Headers';

  static const String Origin = 'Origin';

  static const String RequestMethod = 'Access-Control-Request-Method';

  static const String RequestHeaders = 'Access-Control-Request-Headers';
}

class WrapCors implements RouteWrapper<Cors> {
  final String id;

  final Map<Symbol, MakeParam> makeParams;

  final CorsOptions options;

  const WrapCors(this.options, {this.id, this.makeParams});

  Cors createInterceptor() => new Cors(options);
}

class Cors extends Interceptor {
  final CorsOptions options;

  Cors(this.options);

  CorsRequestParams params;

  bool _isCors = false;

  bool get isCors => _isCors;

  bool _isPreflight = false;

  bool get isPreflight => _isPreflight;

  String _errorMsg;

  String get errorMsg => _errorMsg;

  bool get hasError => _errorMsg != null;

  void pre(Request req) {
    params = new CorsRequestParams.fromRequest(req);

    //Check if it is CORS request
    if (params.origin is! String) {
      if (!options.allowNonCorsRequests) {
        throw new JaguarError(404, 'Not a Cross origin request!',
            "Only Cross origin requests are allowed!");
      }
      return;
    }

    _isCors = true;

    if (req.method == 'OPTIONS' && params.method is String) {
      _isPreflight = true;
    }

    _filterOrigin();

    if (errorMsg == null) {
      _filterMethods(req);
    }

    if (errorMsg == null) {
      _filterHeaders(req);
    }

    if (errorMsg != null) {
      throw new JaguarError(403, 'Invalid CORS request', errorMsg);
    }
  }

  void _filterOrigin() {
    if (options.allowAllOrigins) return;

    if (options.allowedOrigins == null) {
      _errorMsg = 'Origin not allowed!';
      return;
    }

    if (!options.allowedOrigins.contains(params.origin)) {
      _errorMsg = 'Origin not allowed!';
      return;
    }
  }

  void _filterMethods(Request req) {
    String method;

    if (isPreflight) {
      method = params.method;
    } else {
      method = req.method;
    }

    if (options.allowAllMethods) return;

    if (options.allowedMethods.length == 0) {
      _errorMsg = 'Method not allowed!';
      return;
    }

    if (!options.allowedMethods.contains(method)) {
      _errorMsg = 'Method not allowed!';
      return;
    }
  }

  void _filterHeaders(Request req) {
    final List<String> headers = [];

    if (isPreflight) {
      if (params.headers is List<String>) {
        headers.addAll(params.headers);
      }
    } else {
      req.headers.forEach((String header, _) => headers.add(header));
    }

    if (headers.length == 0) return;

    if (options.allowAllHeaders) return;

    if (options.allowedHeaders == null) {
      _errorMsg = 'Header not allowed!';
      return;
    }

    for (String header in headers) {
      if (!options.allowedHeaders.contains(header)) {
        _errorMsg = 'Header not allowed!';
        return;
      }
    }
  }

  Response<ResponseType> post<ResponseType>(
      @InputRouteResponse() Response<ResponseType> response) {
    if (!isCors) return response;

    if (hasError) return response;

    if (options.allowAllOrigins) {
      response.headers.set(CorsHeaders.AllowedOrigin, '*');
    } else {
      response.headers
          .set(CorsHeaders.AllowedOrigin, options.allowedOrigins.join(', '));
    }

    if (options.vary) {
      response.headers.set(CorsHeaders.Vary, 'true');
    }

    if (options.allowCredentials) {
      response.headers.set(CorsHeaders.AllowCredentials, 'true');
    }

    if (isPreflight) {
      if (options.allowAllMethods) {
        response.headers.set(CorsHeaders.AllowedMethods, '*');
      } else if (options.allowedMethods.length != 0) {
        response.headers
            .set(CorsHeaders.AllowedMethods, options.allowedMethods.join(', '));
      }

      if (options.allowAllHeaders) {
        response.headers.set(CorsHeaders.AllowedHeaders, '*');
      } else if (options.allowedHeaders.length != 0) {
        response.headers
            .set(CorsHeaders.AllowedHeaders, options.allowedHeaders.join(', '));
      }

      if (options.maxAge is int) {
        response.headers.set(CorsHeaders.MaxAge, options.maxAge.toString());
      }

      response.statusCode = 200;
    } else {
      if (options.exposeAllHeaders) {
        response.headers.set(CorsHeaders.ExposeHeaders, '*');
      } else if (options.exposeHeaders.length != 0) {
        response.headers
            .set(CorsHeaders.ExposeHeaders, options.exposeHeaders.join(', '));
      }
    }

    return response;
  }
}

class CorsRequestParams {
  final String origin;

  final String method;

  final List<String> headers;

  bool get isCors => origin is String;

  CorsRequestParams._(this.origin, this.method, this.headers);

  factory CorsRequestParams.fromRequest(Request req) {
    final String origin = req.headers.value(CorsHeaders.Origin);

    if (origin is! String) return new CorsRequestParams._(null, null, null);

    String method;
    {
      dynamic value = req.headers.value(CorsHeaders.RequestMethod);
      if (value is String) {
        method = value;
      }
    }

    final List<String> headers = [];
    {
      dynamic value = req.headers.value(CorsHeaders.RequestHeaders);
      if (value is String) {
        headers.addAll(value.split(','));
      }
    }

    return new CorsRequestParams._(origin, method, headers);
  }
}
