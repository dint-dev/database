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

/// Describes distance to go for reading/writing data.
enum Reach {
  /// Truth in the local device. This reach has the best latency, it doesn't
  /// consume network traffic, and it's never unavailable.
  local,

  /// A possibly out-of-date, inconsistent, or partial view at the global truth
  /// such as a slowly indexing search engine.
  ///
  /// In terms of latency and availability, this level is much worse than
  /// [Reach.local], but better than [Reach.regionalMaster].
  internet,

  /// The regional master truth. May diverge from the global truth during
  /// network partitions, but this is rare.
  regionalMaster,

  /// The global master truth.
  globalMaster,
}
