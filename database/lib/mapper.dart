// Copyright 2019 Gohilla Ltd.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Object mapper system for databases.
///
/// Currently supports:
///   * [built_value](https://pub.dev/packages/built_value) serialization.
///   * [protobuf](https://pub.dev/packages/protobuf) serialization.
///
/// ## Example
/// ```
/// import 'package:database/database.dart';
/// import 'package:database/mapper.dart';
///
/// void main() {
///   final database = MemoryDatabaseAdapter().database();
///   // ...
/// }
library database.mapper;

export 'src/mapper/built_value_mapper.dart';
export 'src/mapper/mapper.dart';
export 'src/mapper/protobuf_mapper.dart';
