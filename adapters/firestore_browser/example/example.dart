import 'package:database/database.dart';
import 'package:database_adapter_firestore_browser/database_adapter_firestore_browser.dart';

Database getDatabase() {
  return FirestoreBrowser(
    appId: 'Your application ID',
    apiKey: 'Your API key',
  );
}
