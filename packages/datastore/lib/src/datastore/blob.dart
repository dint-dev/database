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

import 'dart:convert';

import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart';

/// A sequence of bytes. The bytes don't need to fit in the memory.
abstract class Blob {
  const Blob();

  /// Constructs a blob that contains the bytes.
  factory Blob.fromBytes(List<int> data) = _BytesBlob;

  /// Constructs a blob that contains the JSON, encoded with UTF-8.
  factory Blob.fromJson(Object value) {
    return Blob.fromString(json.encode(value));
  }

  /// Constructs a blob that contains the string, encoded with UTF-8.
  const factory Blob.fromString(String s) = _StringBlob;

  factory Blob.fromUri(String uri, {HttpClient httpClient}) = _UriBlob;

  /// Reads possible metadata.
  Future<BlobMetadata> getBlobMetadata() {
    return Future<BlobMetadata>.value(const BlobMetadata());
  }

  /// Reads the blob as a stream of chunks.
  ///
  /// Optional callback [onBlobMetadata], when non-null, will be invoked exactly
  /// once before the stream ends (unless an error occurs).
  Stream<List<int>> read({
    void Function(BlobMetadata metadata) onBlobMetadata,
  });

  /// Reads the blob as bytes.
  ///
  /// Optional callback [onBlobMetadata], when non-null, will be invoked exactly
  /// once before the future is completed (unless an error occurs).
  /// The callback receives an instance [BlobMetadata], which may contain
  /// metadata about the blob. For example, HTTP header often contains MIME type
  /// and length.
  Future<List<int>> readAsBytes({
    void Function(BlobMetadata metadata) onBlobMetadata,
  }) async {
    final chunks = await read(
      onBlobMetadata: onBlobMetadata,
    ).toList();
    switch (chunks.length) {
      case 0:
        return List<int>(0);
      case 1:
        return chunks.single;
      default:
        final length = chunks.fold(0, (n, list) => n + list.length);
        final result = List<int>(length);
        var i = 0;
        for (var chunk in chunks) {
          result.setAll(i, chunk);
          i += chunk.length;
        }
        return result;
    }
  }

  /// Reads the blob as a JSON tree.
  ///
  /// Optional callback [onBlobMetadata], when non-null, will be invoked exactly
  /// once before the future is completed (unless an error occurs).
  Future<Object> readAsJson({
    void Function(BlobMetadata metadata) onBlobMetadata,
  }) async {
    final string = await readAsString(
      onBlobMetadata: onBlobMetadata,
    );
    return const JsonDecoder().convert(string);
  }

  /// Reads the blob as a string.
  ///
  /// Optional callback [onBlobMetadata], when non-null, will be invoked exactly
  /// once before the future is completed (unless an error occurs).
  Future<String> readAsString({
    void Function(BlobMetadata metadata) onBlobMetadata,
  }) async {
    final bytes = await readAsBytes(
      onBlobMetadata: onBlobMetadata,
    );
    return const Utf8Decoder().convert(bytes);
  }
}

/// Metadata about [Blob].
class BlobMetadata {
  final int length;
  final String mime;
  const BlobMetadata({this.length, this.mime});

  @override
  int get hashCode => length.hashCode ^ mime.hashCode;

  @override
  bool operator ==(other) =>
      other is BlobMetadata && length == other.length && mime == other.mime;
}

/// An exception thrown by [Blob].
class BlobReadException implements Exception {
  final Blob blob;
  final String message;
  final Object error;

  BlobReadException({this.blob, this.message, this.error});

  @override
  String toString() => 'Reading blob failed: ${message ?? error}';
}

class _BytesBlob extends Blob {
  final List<int> _data;

  _BytesBlob(this._data);

  @override
  Stream<List<int>> read(
      {void Function(BlobMetadata metadata) onBlobMetadata}) {
    return Stream<List<int>>.value(_data);
  }
}

class _StringBlob extends Blob {
  final String _data;

  const _StringBlob(this._data) : assert(_data != null);

  @override
  int get hashCode => _data.hashCode;

  @override
  bool operator ==(other) => other is _StringBlob && _data == other._data;

  @override
  Stream<List<int>> read({
    void Function(BlobMetadata metadata) onBlobMetadata,
  }) async* {
    yield (await readAsBytes());
  }

  @override
  Future<List<int>> readAsBytes({
    void Function(BlobMetadata metadata) onBlobMetadata,
  }) async {
    return utf8.encode(_data);
  }

  @override
  Future<String> readAsString({
    void Function(BlobMetadata metadata) onBlobMetadata,
  }) async {
    return _data;
  }

  @override
  String toString() => 'Blob.fromString(..)';
}

/// Data that can be loaded from an URI.
///
/// The following schemes are supported by default:
///   * "file" (example: "file:example.jpeg")
///   * "package" (example: "package:my_package/example.jpeg")
///   * "http" and "https"
class _UriBlob extends Blob {
  /// URI of the data.
  final Uri uri;

  /// Optional [httpClient] defines HTTP client that should be used to read the
  /// resource (when the scheme is "http" or "https").
  final HttpClient httpClient;

  _UriBlob(String uri, {HttpClient httpClient})
      : this.fromUri(Uri.parse(uri), httpClient: httpClient);

  _UriBlob.fromUri(this.uri, {this.httpClient}) {
    if (uri == null) {
      throw ArgumentError.notNull('uri');
    }
  }

  @override
  int get hashCode => uri.hashCode;

  Uri get resolvedUri {
    final uri = this.uri;
    if (uri.scheme ?? '' == '') {
      return uri;
    }
    if (uri.host != null) {
      return uri.replace(scheme: 'file');
    }
    final href = Uri.parse(html.document?.baseUri ?? '');
    if (href.scheme.startsWith('http')) {
      return href.resolveUri(uri);
    } else {
      return Directory.current.uri.resolveUri(uri);
    }
  }

  @override
  bool operator ==(other) =>
      other is _UriBlob && uri == other.uri && httpClient == other.httpClient;

  @override
  Stream<List<int>> read({
    void Function(BlobMetadata metadata) onBlobMetadata,
  }) {
    final uri = resolvedUri;
    final scheme = uri.scheme;
    if (scheme == 'http' || scheme == 'https') {
      return _httpAsBytesStream(onBlobMetadata);
    }
    throw UnsupportedError('Unsupported scheme in URI: $uri');
  }

  @override
  String toString() {
    if (httpClient == null) {
      return "Blob.fromUri('$uri')";
    }
    return "Blob.fromUri('$uri', httpClient:...)";
  }

  Stream<List<int>> _httpAsBytesStream(
    void Function(BlobMetadata metadata) onBlobMetadata,
  ) async* {
    // Create request
    final httpClient = this.httpClient ?? HttpClient();
    final httpRequest = await httpClient.getUrl(uri);

    // Wait for response
    final httpResponse = await httpRequest.close();

    // Announce response
    if (onBlobMetadata != null) {
      onBlobMetadata(BlobMetadata(
        length: httpResponse.contentLength,
        mime: httpResponse.headers.contentType?.mimeType,
      ));
    }

    // Validate status
    final statusCode = httpResponse.statusCode;
    if (statusCode != 200) {
      throw StateError('Unexpected HTTP response status: $statusCode');
    }

    // Yield
    yield* (httpResponse);
  }
}
