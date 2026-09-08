// Copyright (c) 2026 Contributors to the Suwayomi project
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Selecting a library and pressing Download to server used to queue every
// chapter of every series, so a 85-series selection put over 13,000 entries in
// the server's queue when only a few hundred were actually missing.

import 'package:flutter_test/flutter_test.dart';
import 'package:tsumiru/src/features/library/presentation/library/category_manga_list.dart';

import '../manga_book/manga_details/chapter_test_helpers.dart';

void main() {
  group('serverDownloadIds', () {
    test('skips chapters the server already holds', () {
      final ids = serverDownloadIds([
        ch(id: 1, number: 1, isDownloaded: true),
        ch(id: 2, number: 2),
        ch(id: 3, number: 3, isDownloaded: true),
        ch(id: 4, number: 4),
      ]);
      expect(ids, [2, 4]);
    });

    test('a fully downloaded series queues nothing', () {
      final ids = serverDownloadIds([
        ch(id: 1, number: 1, isDownloaded: true),
        ch(id: 2, number: 2, isDownloaded: true),
      ]);
      expect(ids, isEmpty);
    });

    test('a null chapter list queues nothing', () {
      expect(serverDownloadIds(null), isEmpty);
    });
  });
}
