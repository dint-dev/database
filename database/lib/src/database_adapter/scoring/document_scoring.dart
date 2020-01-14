// Copyright 2019 terrier989@gmail.com.
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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';

/// Assesses how well seen documents match a filter.
///
/// The choice of algorithm only affects queries with non-exact filters such as
/// natural language keywords.
class DocumentScoring {
  const DocumentScoring();

  /// Constructs a state that is used for evaluating each seen document during
  /// a single query.
  ///
  /// The default implementation returns [DocumentScoringStateBase].
  DocumentScoringState newState(Filter filter) {
    return DocumentScoringStateBase(filter);
  }

  /// Constructs a state that is used for evaluating each seen document during
  /// a single query.
  ///
  /// The default implementation evaluates [KeywordFilter] with a simple
  /// substring search.
  DocumentScoringState newStateFromQuery(Query query) {
    return newState(query.filter);
  }
}

/// State constructed by [DocumentScoring] for each query.
abstract class DocumentScoringState {
  /// Returns a positive number if the document snapshot matches the filter.
  /// Otherwise returns 0.0.
  double evaluateSnapshot(Snapshot snapshot);
}
