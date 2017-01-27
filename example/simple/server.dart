library example.simple;

import 'package:jaguar/jaguar.dart';
import 'package:jaguar_mux/jaguar_mux.dart';
import 'package:jaguar_cors/jaguar_cors.dart';

main() async {
  final builder = new MuxBuilder();

  {
    String handler() {
      return 'none';
    }

    builder.get('/none', handler).wrap(new WrapCors(new CorsOptions()));
  }

  {
    String handler() => 'origins';
    final options = new CorsOptions(
        allowedOrigins: ['http://example.com', 'http://example1.com'],
        allowAllMethods: true,
        allowAllHeaders: true);
    builder.get('/origins', handler).wrap(new WrapCors(options));
  }

  {
    String handler() {
      return 'preflight';
    }

    final options = new CorsOptions(
        allowedOrigins: ['http://example.com'],
        allowAllMethods: true,
        allowAllHeaders: true);
    builder.route('/preflight', handler,
        methods: ['OPTIONS']).wrap(new WrapCors(options));
  }

  Configuration conf = new Configuration();
  conf.addApi(builder.build());
  await serve(conf);
}
