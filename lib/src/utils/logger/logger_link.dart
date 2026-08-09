import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';

import 'logger.dart';

/// Counts GraphQL operations in debug builds so query volume can be measured
/// rather than guessed — the app caches nothing (`FetchPolicy.noCache`), so
/// every screen rebuild re-asks the server the same question and nobody knew
/// what that costs. Debug-only; release builds pay nothing.
class GraphQLRequestStats {
  static final Map<String, int> _counts = {};
  static int total = 0;

  static void record(String operation) {
    total++;
    _counts[operation] = (_counts[operation] ?? 0) + 1;
  }

  /// Operations by call count, most-repeated first. A high count for a
  /// slow-changing operation is a caching candidate; a volatile one is not.
  static String report() {
    final sorted = _counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final lines = [
      for (final e in sorted.take(25))
        '  ${e.value.toString().padLeft(5)}  ${e.key}',
    ];
    return 'GraphQL: $total requests, ${_counts.length} distinct operations\n'
        '${lines.join('\n')}';
  }

  static void reset() {
    _counts.clear();
    total = 0;
  }
}

class LoggerLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    if (kDebugMode) {
      final name = request.operation.operationName ?? 'unnamed';
      GraphQLRequestStats.record(name);
      // Every 25th request, dump the tally — frequent enough to watch live in
      // logcat without a line per call drowning everything else out.
      if (GraphQLRequestStats.total % 25 == 0) {
        logger.i(GraphQLRequestStats.report());
      }
    }
    Stream<Response> response = forward!(request)
        .map((Response fetchResult) => fetchResult)
        .handleError((error) {
          throw error;
        });

    return response;
  }

  LoggerLink();
}
