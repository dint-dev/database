import 'package:database/database.dart';
import 'package:database_adapter_elasticsearch/database_adapter_elasticsearch.dart';

Future main() async {
  // Set up
  final database = ElasticSearch(
    host: 'localhost',
    credentials: ElasticSearchPasswordCredentials(
      user: 'example user',
      password: 'example password',
    ),
  );
  final collection = database.collection('example');

  // Insert a document
  final document = await collection.insert(data: {'greeting': 'Hello world!'});
  print('Inserted ID: ${document.documentId}');

  // Search documents
  final results = await collection.search(
    query: Query.parse(
      'world hello',
      skip: 0,
      take: 10,
    ),
  );
  print('Found ${results.items} results');
}
