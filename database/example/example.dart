import 'package:database/database.dart';

void main() async {
  // Choose a database
  final database = MemoryDatabase();

  // Search
  final response = await database.collection('people').search(
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
