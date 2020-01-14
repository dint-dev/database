import 'package:database/database.dart';
import 'package:search/search.dart';

void main() async {
  // Set default database
  final database = SearcheableDatabase(
    database: MemoryDatabase(),
    isReadOnly: true,
  );

  // Search items
  final collection = database.collection('employee');
  final response = await collection.search(
    query: Query.parse('"software developer" (dart OR javascript)'),
  );

  // Print items
  for (var snapshot in response.snapshots) {
    print('Document ID: ${snapshot.document.documentId}');
  }
}
