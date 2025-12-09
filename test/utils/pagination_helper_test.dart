import 'package:flutter_test/flutter_test.dart';
import 'package:scc_app/core/utils/pagination_helper.dart';

void main() {
  group('PaginationHelper', () {
    test('should return correct page items', () {
      final items = List.generate(50, (i) => 'Item $i');
      final helper = PaginationHelper(items: items, itemsPerPage: 10);

      expect(helper.totalPages, 5);
      expect(helper.getPage(1).length, 10);
      expect(helper.getPage(1).first, 'Item 0');
      expect(helper.getPage(5).last, 'Item 49');
    });

    test('hasNextPage and hasPreviousPage should work', () {
      final items = List.generate(25, (i) => 'Item $i');
      final helper = PaginationHelper(items: items, itemsPerPage: 10);

      expect(helper.hasNextPage(1), true);
      expect(helper.hasNextPage(3), false);
      expect(helper.hasPreviousPage(1), false);
      expect(helper.hasPreviousPage(2), true);
    });
  });
}

