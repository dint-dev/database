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
