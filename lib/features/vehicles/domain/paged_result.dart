/// One page of a list, as Spring Data returns it:
/// `{"content": [...], "page": {"size", "number", "totalElements", "totalPages"}}`.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  bool get isEmpty => items.isEmpty;

  bool get hasPrevious => pageNumber > 0;

  bool get hasNext => pageNumber + 1 < totalPages;

  /// One-based index of the first row on this page, or 0 when there are none.
  int get firstItemIndex => totalItems == 0 ? 0 : pageNumber * pageSize + 1;

  /// One-based index of the last row on this page.
  int get lastItemIndex => pageNumber * pageSize + items.length;

  static PagedResult<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) readItem,
  ) {
    final List<dynamic> content = (json['content'] as List<dynamic>?) ?? <dynamic>[];
    final Map<String, dynamic> page = Map<String, dynamic>.from(
      (json['page'] as Map?) ?? <String, dynamic>{},
    );

    int readInt(String key) => (page[key] as num?)?.toInt() ?? 0;

    return PagedResult<T>(
      items: content
          .map((dynamic item) => readItem(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      pageNumber: readInt('number'),
      pageSize: readInt('size'),
      totalItems: readInt('totalElements'),
      totalPages: readInt('totalPages'),
    );
  }

  static PagedResult<T> empty<T>() => PagedResult<T>(
    items: <T>[],
    pageNumber: 0,
    pageSize: 0,
    totalItems: 0,
    totalPages: 0,
  );
}
