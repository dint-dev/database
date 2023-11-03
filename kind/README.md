# Introduction
This is "package:kind", a Dart package for creating static objects that describe
"what kind of data" you have.

Licensed under the [Apache License 2.0](LICENSE).

## Links
  * [Github project](https://pub.dev/packages/database)
  * [Github issue tracker](https://pub.dev/packages/database/issues)

## Key features
  * __Flexible__
    * The package makes you think many things through, such as:
      * How many bits an integer needs? 32? 52? 64?
      * What is the maximum length of a list?
      * When you convert `DateTime` instances to/from JSON, should you use UTC or local time
        zone?
    * Once you have specified your data model, the package lets you do:
      * JSON serialization
      * Database object mapping
      * Automatic implementation of `==`, `hashCode`, and `toString()`.
      * And more!
  * __No code generation.__
    * You write `Kind<T>` specifications manually (see examples below). However, AI code assistants
      can easily automate the writing.
    * The package also works easily for any class. You don't need to modify the classes themselves.
      You could, for example, serialize Flutter SDK widgets.

Sounds interesting? We encourage you to compare this framework to older, more established packages
such as [json_serializable](https://pub.dev/packages/json_serializable) and pick your favorite.

## Built-in kinds
  * Fixed-length primitives
    * [NullableKind](https://pub.dev/documentation/kind/latest/kind/NullableKind-class.html)
    * [BoolKind](https://pub.dev/documentation/kind/latest/kind/BoolKind-class.html)
    * [IntKind](https://pub.dev/documentation/kind/latest/kind/IntKind-class.html)
      * [IntKind.unsigned](https://pub.dev/documentation/kind/latest/kind/IntKind/unsigned.html)
      * [IntKind.int8](https://pub.dev/documentation/kind/latest/kind/IntKind/int8.html)
      * [IntKind.int16](https://pub.dev/documentation/kind/latest/kind/IntKind/int16.html)
      * [IntKind.int32](https://pub.dev/documentation/kind/latest/kind/IntKind/int32.html)
      * [IntKind.int64](https://pub.dev/documentation/kind/latest/kind/IntKind/int64.html)
      * [IntKind.uint8](https://pub.dev/documentation/kind/latest/kind/IntKind/uint8.html)
      * [IntKind.uint16](https://pub.dev/documentation/kind/latest/kind/IntKind/uint16.html)
      * [IntKind.uint32](https://pub.dev/documentation/kind/latest/kind/IntKind/uint32.html)
      * [IntKind.uint64](https://pub.dev/documentation/kind/latest/kind/IntKind/uint64.html)
    * [FloatKind](https://pub.dev/documentation/kind/latest/kind/FloatKind-class.html)
      * [FloatKind.float32](https://pub.dev/documentation/kind/latest/kind/FloatKind/float32.html)
    * [BigIntKind](https://pub.dev/documentation/kind/latest/kind/BigIntKind-class.html)
    * [DateTimeKind](https://pub.dev/documentation/kind/latest/kind/DateTimeKind-class.html)
    * [DurationKind](https://pub.dev/documentation/kind/latest/kind/DurationKind-class.html)
    * [EnumKind](https://pub.dev/documentation/kind/latest/kind/EnumKind-class.html)
    * [EnumLikeKind](https://pub.dev/documentation/kind/latest/kind/EnumLikeKind-class.html)
  * Variable-length primitives
    * [StringKind](https://pub.dev/documentation/kind/latest/kind/StringKind-class.html)
    * [Uint8ListKind](https://pub.dev/documentation/kind/latest/kind/Uint8ListKind-class.html)
  * Collection classes:
    * [ListKind](https://pub.dev/documentation/kind/latest/kind/ListKind-class.html)
    * [SetKind](https://pub.dev/documentation/kind/latest/kind/SetKind-class.html)
    * [MapKind](https://pub.dev/documentation/kind/latest/kind/MapKind-class.html)
  * Polymorphic values:
    * [PolymorphicKind](https://pub.dev/documentation/kind/latest/kind/PolymorphicKind-class.html)
  * User-defined classes:
    * [CompositeKind](https://pub.dev/documentation/kind/latest/kind/CompositeKind-class.html)
    * [ImmutableKind](https://pub.dev/documentation/kind/latest/kind/ImmutableKind-class.html)
      * Three possible constructors:
        * [ImmutableKind(..)](https://pub.dev/documentation/kind/latest/kind/ImmutableKind/ImmutableKind.html)
        * [ImmutableKind.withConstructor(..)](https://pub.dev/documentation/kind/latest/kind/ImmutableKind/ImmutableKind.withConstructor.html)
        * [ImmutableKind.withMapperMethod(..)](https://pub.dev/documentation/kind/latest/kind/ImmutableKind/ImmutableKind.withMapperMethod.html)

## Things you can do
  * Find classes
    * [Kind.all](https://pub.dev/documentation/kind/latest/kind/Kind/all.html)
    * [Kind.find](https://pub.dev/documentation/kind/latest/kind/Kind/find.html)
    * [Kind.registerAll](https://pub.dev/documentation/kind/latest/kind/Kind/registerAll.html)
  * Construct instances
    * [clone](https://pub.dev/documentation/kind/latest/kind/Kind/clone.html)
    * [newInstance](https://pub.dev/documentation/kind/latest/kind/Kind/newInstance.html)
    * [newList](https://pub.dev/documentation/kind/latest/kind/Kind/newList.html)
  * Validate data:
    * [isValid](https://pub.dev/documentation/kind/latest/kind/Kind/isValid.html)
    * [checkValid](https://pub.dev/documentation/kind/latest/kind/Kind/checkValid.html)
  * Describe data:
    * [debugString](https://pub.dev/documentation/kind/latest/kind/Kind/debugString.html)
  * JSON serialization
    * [encodeJsonTree](https://pub.dev/documentation/kind/latest/kind/Kind/encodeJsonTree.html)
    * [decodeJsonTree](https://pub.dev/documentation/kind/latest/kind/Kind/decodeJsonTree.html)
  * Reflection:
    * [instanceMirror](https://pub.dev/documentation/kind/latest/kind/Kind/instanceMirror.html)

# Getting started
## 1.Add dependency
In terminal, run the following in your project directory:
```
flutter pub add kind
```

Does not work? If your project uses Dart SDK rather than Flutter SDK, run `dart pub add kind`.

## 2.Study examples

See example code below.

# Examples
```dart
import 'package:kind/kind.dart';

void main() {
  //
  // Encode/decode JSON trees:
  //
  final company = Company.kind.decodeJsonTree({
    'name': 'Flutter App Development Experts',
    'shareholders': [
      {
        '@type': 'Person',
        'firstName': 'Alice',
        'lastName': 'Smith',
      },
      {
        '@type': 'Person',
        'firstName': 'Bob',
      },
    ],
  });
  print("${company.name} has ${company.shareholders.length} shareholders.");

  //
  // We have `==` and `hashCode` because we extended `HasKind`:
  //
  print(company.shareholders[1] == Person(firstName: 'Bob')); // --> true

  //
  // We have `toString()` because we extended `HasKind`:
  //
  print(company.toString());
  // Prints:
  //   Company(
  //     "Flutter App Development Experts",
  //     shareholders: [
  //       Person(
  //         firstName: 'John',
  //         lastName: 'Doe',
  //       ),
  //       Person(firstName: 'Bob'),
  //     ],
  //   )
}

//
// Example class #1:
//   "A static `_walk` function"
//
class Company extends Shareholder {
  static const kind = ImmutableKind<Company>(
    name: 'Company',
    blank: Company(''),
    walk: _walk,
  );

  @override
  final String name;

  final List<Shareholder> shareholders;

  const Company(this.name, {this.shareholders = const []});

  @override
  Kind<Company> get runtimeKind => kind;

  static Company _walk(Mapper f, Company t) {
    final name = f.positional(t.name, 'name');
    final shareholders = f(
      t.shareholders,
      'shareholders',
      kind: const ListKind(
        elementKind: Shareholder.kind,
      ),
    );

    // The following is a performance optimization we recommend:
    if (f.canReturnSame) {
      return t;
    }

    // Finally, construct a new instance:
    return Company(
      name,
      shareholders: shareholders,
    );
  }
}

//
// Example #2:
//   "A class that extends `Walkable`"
//
class Person extends Shareholder with Walkable {
  static const kind = ImmutableKind<Person>.walkable(
    name: 'Person',
    blank: Person(firstName: ''),
  );

  /// First name
  final String firstName;

  /// First name
  final String lastName;

  const Person({
    required this.firstName,
    this.lastName = '',
  });

  @override
  String get name => '$firstName $lastName';

  @override
  Kind<Person> get runtimeKind => kind;

  @override
  Person walk(Mapper f) {
    final firstName = f.required(
      this.firstName,
      'firstName',
      kind: const StringKind.singleLineShort(),
    );
    final lastName = f(
      this.lastName,
      'lastName',
      kind: const StringKind.singleLineShort(),
    );
    if (f.canReturnSame) {
      return this;
    }
    return Person(
      firstName: firstName,
      lastName: lastName,
    );
  }
}

//
// Example #3:
//   "A polymorphic class"
//
abstract class Shareholder extends HasKind {
  static const kind = PolymorphicKind<Shareholder>.sealed(
    defaultKinds: [
      Person.kind,
      Company.kind,
    ],
  );

  const Shareholder();

  String get name;
}
```