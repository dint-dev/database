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

abstract class SchemaVisitor<T, C> {
  const SchemaVisitor();
  T visitArbitraryTreeSchema(ArbitraryTreeSchema schema, C context);
  T visitBlobSchema(BlobSchema schema, C context);
  T visitBoolSchema(BoolSchema schema, C context);
  T visitBytesSchema(BytesSchema schema, C context);
  T visitDateTimeSchema(DateTimeSchema schema, C context);
  T visitDocumentSchema(DocumentSchema schema, C context);
  T visitDoubleSchema(DoubleSchema schema, C context);
  T visitGeoPointSchema(GeoPointSchema schema, C context);
  T visitInt64Schema(Int64Schema schema, C context);
  T visitIntSchema(IntSchema schema, C context);
  T visitListSchema(ListSchema schema, C context);
  T visitMapSchema(MapSchema schema, C context);
  T visitStringSchema(StringSchema schema, C context);
}
