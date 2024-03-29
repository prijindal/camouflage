import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import '../helpers/logger.dart';
import './core.dart';

DatabaseConnection connectOnWeb() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'camouflage', // prefer to only use valid identifiers here
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      // Depending how central local persistence is to your app, you may want
      // to show a warning to the user if only unrealiable implemetentations
      // are available.
      AppLogger.instance
          .i('Using ${result.chosenImplementation} due to missing browser '
              'features: ${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  }));
}

SharedDatabase constructDb() {
  return SharedDatabase(connectOnWeb());
}
