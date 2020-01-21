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

/// Describes distance to the global truth.
///
/// For ordinary reads and writes, enforcing [Reach.server] is usually good
/// enough.
///
/// Enforce [Reach.global] when you want to eliminate inconsistent /
/// out-of-date reads and writes completely.
enum Reach {
  /// Truth in the local device.
  local,

  /// A server that has access to all data, but the view may be many seconds
  /// old, inconsistent, or lack some data.
  server,

  /// The regional master truth. May diverge from the global truth during global
  /// network partitions, but this is rare.
  regional,

  /// The global master truth.
  global,
}
