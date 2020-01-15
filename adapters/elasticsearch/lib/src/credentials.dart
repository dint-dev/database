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

import 'package:database_adapter_elasticsearch/database_adapter_elasticsearch.dart';
import 'package:universal_io/io.dart';

/// Superclass for [ElasticSearch] credentials. Currently the only subclass is
/// [ElasticSearchPasswordCredentials].
abstract class ElasticSearchCredentials {
  const ElasticSearchCredentials();

  void prepareHttpClient(
    ElasticSearch engine,
    HttpClient httpClient,
  ) {}

  void prepareHttpClientRequest(
    ElasticSearch engine,
    HttpClientRequest httpClientRequest,
  ) {}
}

class ElasticSearchPasswordCredentials extends ElasticSearchCredentials {
  final String user;
  final String password;
  const ElasticSearchPasswordCredentials({this.user, this.password});

  @override
  void prepareHttpClient(
    ElasticSearch database,
    HttpClient httpClient,
  ) {
    httpClient.addCredentials(
      database.uri.resolve('/'),
      null,
      HttpClientBasicCredentials(
        user,
        password,
      ),
    );
  }
}
