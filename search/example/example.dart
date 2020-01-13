import 'package:database/database.dart';
import 'package:search/search.dart';

void main() async {
  // Set default database
  Database.freezeDefaultInstance(
    SearcheableDatabase(
      database: MemoryDatabase(),
      isReadOnly: true,
    ),
  );

  // ...

  final database = Database.defaultInstance;
  final collection = database.collection('employee');
  final response = await collection.search(
    query: Query.parse('"software developer" (dart OR javascript)'),
  );
  for (var snapshot in response.snapshots) {
    print('Document ID: ${snapshot.document.documentId}');
  }
}
