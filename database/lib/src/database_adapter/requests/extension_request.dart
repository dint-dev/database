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

import 'package:database/database_adapter.dart';

/// Describes an vendor-specific operation that [DatabaseAdapter] should
/// perform. The response is a stream of [DatabaseExtensionResponse] objects.
abstract class DatabaseExtensionRequest<T extends DatabaseExtensionResponse>
    extends Request<Stream<T>> {
  @override
  Stream<T> delegateTo(DatabaseAdapter adapter) {
    return adapter.performExtension(this);
  }

  /// Called by a leaf adapter that doesn't support the request.
  Stream<T> unsupported(DatabaseAdapter adapter) {
    return Stream<T>.error(
      UnsupportedError('Request class $this is unsupported by $adapter'),
    );
  }
}

/// A superclass for results of vendor-specific operations
/// ([DatabaseExtensionRequest]).
abstract class DatabaseExtensionResponse {}
