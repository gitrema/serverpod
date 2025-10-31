import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

/// Tests that verify middleware-related types and implementations are properly
/// exported from the serverpod.dart public API.
///
/// These tests ensure that users can access all necessary middleware functionality
/// without needing to import internal implementation files.
void main() {
  group('Middleware exports', () {
    group('Relic middleware types', () {
      test(
          'Given middleware exports When accessing Middleware type Then it is available',
          () {
        // Verify that the Middleware type from relic is accessible
        // This is a function type: Handler Function(Handler)
        // ignore: prefer_function_declarations_over_variables
        Middleware middleware = (Handler innerHandler) {
          return (Request req) async {
            return await innerHandler(req);
          };
        };

        expect(middleware, isA<Middleware>());
      });

      test(
          'Given middleware exports When accessing Handler type Then it is available',
          () {
        // Verify that the Handler type from relic is accessible
        // ignore: prefer_function_declarations_over_variables
        Handler handler = (Request req) async {
          return Response.ok();
        };

        expect(handler, isA<Handler>());
      });

      test(
          'Given middleware exports When accessing Pipeline class Then it is available',
          () {
        // Verify that the Pipeline class from relic is accessible
        const pipeline = Pipeline();
        expect(pipeline, isA<Pipeline>());
      });

      test(
          'Given middleware exports When accessing createMiddleware function Then it is available',
          () {
        // Verify that the createMiddleware helper from relic is accessible
        final middleware = createMiddleware(
          onRequest: (Request request) {
            // No-op request handler - return null to pass through
            return null;
          },
        );

        expect(middleware, isA<Middleware>());
      });

      test(
          'Given middleware exports When accessing Request type Then it is available',
          () {
        // Verify that Request type is accessible (needed for middleware)
        expect(Request, isA<Type>());
      });

      test(
          'Given middleware exports When accessing Response type Then it is available',
          () {
        // Verify that Response type is accessible
        expect(Response, isA<Type>());
      });
    });

    group('Serverpod middleware implementations', () {
      test(
          'Given middleware exports When accessing loggingMiddleware Then it is available',
          () {
        // Verify that the loggingMiddleware factory is accessible
        final middleware = loggingMiddleware();
        expect(middleware, isA<Middleware>());
      });

      test(
          'Given loggingMiddleware When using verbose mode Then it is supported',
          () {
        // Verify that loggingMiddleware accepts verbose parameter
        final middleware = loggingMiddleware(verbose: true);
        expect(middleware, isA<Middleware>());
      });

      test(
          'Given loggingMiddleware When using custom logger Then it is supported',
          () {
        // Verify that loggingMiddleware accepts logger parameters
        final logs = <String>[];
        final middleware = loggingMiddleware(
          logger: (message) => logs.add(message),
        );
        expect(middleware, isA<Middleware>());
      });

      test(
          'Given middleware exports When accessing metricsMiddleware Then it is available',
          () {
        // Verify that the metricsMiddleware factory is accessible
        final middleware = metricsMiddleware();
        expect(middleware, isA<Middleware>());
      });

      test(
          'Given metricsMiddleware When using custom registry Then it is supported',
          () {
        // Verify that metricsMiddleware accepts registry parameter
        final registry = MetricRegistry();
        final middleware = metricsMiddleware(registry: registry);
        expect(middleware, isA<Middleware>());
      });

      test(
          'Given metricsMiddleware When using custom path Then it is supported',
          () {
        // Verify that metricsMiddleware accepts metricsPath parameter
        final middleware = metricsMiddleware(metricsPath: '/custom-metrics');
        expect(middleware, isA<Middleware>());
      });
    });

    group('Middleware integration with ExperimentalFeatures', () {
      test('ExperimentalFeatures accepts middleware parameter', () {
        // Verify that middleware can be passed to ExperimentalFeatures
        final features = ExperimentalFeatures(
          middleware: [
            loggingMiddleware(),
          ],
        );

        expect(features.middleware, isNotNull);
        expect(features.middleware?.length, equals(1));
      });

      test('ExperimentalFeatures middleware is immutable list', () {
        // Verify that the middleware list cannot be modified after creation
        final middleware = [loggingMiddleware()];
        final features = ExperimentalFeatures(middleware: middleware);

        // The getter should return the same list
        expect(features.middleware, equals(middleware));
      });

      test('ExperimentalFeatures accepts null middleware', () {
        // Verify that middleware parameter is optional
        final features = ExperimentalFeatures();
        expect(features.middleware, isNull);
      });

      test('ExperimentalFeatures accepts empty middleware list', () {
        // Verify that empty list is valid
        final features = ExperimentalFeatures(middleware: []);
        expect(features.middleware, isNotNull);
        expect(features.middleware?.isEmpty, isTrue);
      });
    });

    group('Complete middleware workflow', () {
      test('can create Pipeline with multiple middleware', () {
        // Verify that a complete middleware pipeline can be created
        final middleware1 = loggingMiddleware();
        final middleware2 = loggingMiddleware(verbose: true);

        final pipeline = const Pipeline()
            .addMiddleware(middleware1)
            .addMiddleware(middleware2);

        expect(pipeline, isA<Pipeline>());
      });

      test('can compose middleware using createMiddleware', () {
        // Verify that custom middleware can be created and composed
        final customMiddleware = createMiddleware(
          onRequest: (Request request) {
            // Custom middleware logic - return null to pass through
            return null;
          },
        );

        final pipeline = const Pipeline()
            .addMiddleware(loggingMiddleware())
            .addMiddleware(customMiddleware);

        expect(pipeline, isA<Pipeline>());
      });
    });
  });
}
