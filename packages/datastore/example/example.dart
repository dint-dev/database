import 'package:datastore/datastore.dart';

void main() async {
  // Choose a datastore
  final datastore = Datastore.defaultInstance;

  // Search
  final response = await datastore.collection('people').search(
        query: Query.parse(
          '"software developer" (dart OR javascript)',
          take: 10,
        ),
      );

  // Print results
  for (var snapshot in response.snapshots) {
    print('Employee ID: ${snapshot.document.documentId}');
    print('Employee name: ${snapshot.data['name']}');
    print('');
  }
}
