import 'package:datastore/adapters.dart';
import 'package:datastore/datastore.dart';
import 'package:search/search.dart';

void main() async {
  // Set default datastore
  Datastore.freezeDefaultInstance(
    SearcheableDatastore(
      datastore: MemoryDatastore(),
      isReadOnly: true,
    ),
  );

  // ...

  final datastore = Datastore.defaultInstance;
  final collection = datastore.collection('employee');
  final response = await collection.search(
    query: Query.parse('"software developer" (dart OR javascript)'),
  );
  for (var snapshot in response.snapshots) {
    print('Document ID: ${snapshot.document.documentId}');
  }
}
