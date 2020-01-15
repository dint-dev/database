import 'package:database/database.dart';
import 'package:database_adapter_algolia/database_adapter_algolia.dart';

Database getSearchEngine() {
  return Algolia(
    appId: 'Your application ID',
    apiKey: 'Your API key',
  );
}
