class PaginationHelper<T> {
  final List<T> allItems;
  final int itemsPerPage;

  PaginationHelper({
    required this.allItems,
    this.itemsPerPage = 20,
  });

  int get totalPages => (allItems.length / itemsPerPage).ceil();
  int get totalItems => allItems.length;

  List<T> getPage(int page) {
    if (page < 1) page = 1;
    if (page > totalPages) page = totalPages;

    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    if (startIndex >= allItems.length) {
      return [];
    }

    return allItems.sublist(
      startIndex,
      endIndex > allItems.length ? allItems.length : endIndex,
    );
  }

  bool hasNextPage(int currentPage) => currentPage < totalPages;
  bool hasPreviousPage(int currentPage) => currentPage > 1;
}

