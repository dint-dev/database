import 'package:datastore/adapters.dart';
import 'package:datastore/datastore.dart';
import 'package:search/search.dart';
import 'package:test/test.dart';

void main() {
  test('SimpleDatastore', () async {
    final datastore = SearcheableDatastore(
      datastore: MemoryDatastore(),
    );
    final collection = datastore.collection('greetings');

    // Insert
    final document0 = collection.document('hello');
    await document0.upsert(data: {
      'greeting': 'Hello world!',
    });

    // Insert
    final document1 = collection.document('hi');
    await document1.upsert(
      data: {
        'greeting': 'Hi world!',
      },
    );

    // Get
    expect(
      await document0.getIncrementalStream().last,
      Snapshot(
        document: document0,
        data: {'greeting': 'Hello world!'},
      ),
    );
    expect(
      await document1.getIncrementalStream().last,
      Snapshot(
        document: document1,
        data: {'greeting': 'Hi world!'},
      ),
    );
    expect(
      (await collection.search()).snapshots,
      hasLength(2),
    );

    // Search
    {
      final results = await collection.search(
        query: Query(
          filter: MapFilter({'greeting': KeywordFilter('Hello world!')}),
        ),
      );
      expect(results.collection, same(collection));
      expect(results.snapshots, hasLength(1));
      expect(results.items, hasLength(1));
      expect(results.items.single.snapshot.document.parent, same(collection));
      expect(results.items.single.snapshot.data, {'greeting': 'Hello world!'});
    }

    // Search
    {
      final query = Query.parse('"Hello world!"');
      expect(
        query,
        Query(filter: KeywordFilter('Hello world!')),
      );
      final results = await collection.search(query: query);
      expect(results.collection, same(collection));
      expect(results.snapshots, hasLength(1));
      expect(results.items, hasLength(1));
      expect(results.items.single.snapshot.document.parent, same(collection));
      expect(results.items.single.snapshot.data, {'greeting': 'Hello world!'});
    }

    // Search
    {
      final query = Query.parse('Hello');
      expect(
        query,
        Query(filter: KeywordFilter('Hello')),
      );
      final results = await collection.search(query: query);
      expect(results.collection, same(collection));
      expect(results.snapshots, hasLength(1));
      expect(results.items, hasLength(1));
      expect(results.items.single.snapshot.document.parent, same(collection));
      expect(results.items.single.snapshot.data, {'greeting': 'Hello world!'});
    }

    // Search
//    {
//      final query = Query.parse('hEllo');
//      expect(
//        query,
//        Query(filter: KeywordFilter('hEllo')),
//      );
//      final results = await collection.search(query: query);
//      expect(results.collection, same(collection));
//      expect(results.snapshots, hasLength(1));
//      expect(results.items, hasLength(1));
//      expect(results.items.single.snapshot.document.parent, same(collection));
//      expect(results.items.single.snapshot.data, {'greeting': 'Hello world!'});
//    }
  });
}
