import 'package:database/database.dart';
import 'package:database_adapter_firestore_flutter/database_adapter_firestore_flutter.dart';

Database getDatabase() {
  return FirestoreFlutter(
    appId: 'Your application ID',
    apiKey: 'Your API key',
  );
}
