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

import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/schema.dart';
import 'package:meta/meta.dart';

@sealed
class DocumentReadRequest extends Request<Stream<Snapshot>> {
  final Transaction transaction;
  final Document document;
  final Reach reach;
  Schema outputSchema;

  DocumentReadRequest({
    this.transaction,
    @required this.document,
    @required this.reach,
    this.outputSchema,
  });

  @override
  Stream<Snapshot> delegateTo(DatabaseAdapter adapter) {
    return adapter.performDocumentRead(this);
  }
}
