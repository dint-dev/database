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

/// Describes how far reads/writes should reach before they are good enough.
///
/// The possible values are:
///   * [Reach.local] - The local cache. You get the best resiliency (and best
///     reading/writing latency), but risk of inconsistent state is high.
///   * [Reach.server] - The fastest (cloud) database or search engine. Often
///     diverges from the regional master database. For example, it's usual for
///     search engine clusters to take seconds or minutes before they have
///     indexed changes in the regional master.
///   * [Reach.regional] - The regional master. May diverge from the global
///     master database during (extremely rare) network partitions.
///   * [Reach.global] - The global master. You get the worst resiliency and
///     best possible consistency.
///
/// Example:
/// ```
/// final snapshot = await document.get(reach: Reach.local);
/// ```
enum Reach {
  /// Local cache.
  local,

  /// The fastest cloud database or search engine.
  server,

  /// Regional master database.
  regional,

  /// Global master database.
  global,
}
