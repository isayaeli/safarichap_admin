import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/app_config.dart';
import 'package:safarichap_admin/src/core/utils/debouncer.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import 'package:safarichap_admin/src/data/models/result.dart';

/// List state shared by every table: page, search, filters and ordering are
/// sent as DRF query params (`?page=2&search=asha&status=active&ordering=-created_at`).
abstract class PagedController<T> extends GetxController {
  final items = <T>[].obs;
  final count = 0.obs;
  final page = 1.obs;
  final isLoading = false.obs;
  final search = ''.obs;
  final filters = <String, dynamic>{}.obs;
  final ordering = RxnString();

  final _debouncer = Debouncer();

  /// Filters applied before the user changes anything (e.g. KYC → pending).
  Map<String, dynamic> get initialFilters => const {};

  Future<Result<Paginated<T>>> fetch(Map<String, dynamic> query);

  int get pageCount =>
      count.value == 0 ? 1 : ((count.value - 1) ~/ AppConfig.pageSize) + 1;

  Map<String, dynamic> get query => {
    'page': page.value,
    'page_size': AppConfig.pageSize,
    'search': search.value,
    'ordering': ordering.value,
    ...filters,
  };

  @override
  void onInit() {
    filters.addAll(initialFilters);
    super.onInit();
  }

  Future<void> load({int? toPage}) async {
    if (toPage != null) page.value = toPage;
    await fetch(query).execute((result) {
      isLoading.value = result is Loading;
      if (result is Success) {
        final data = result.data as Paginated<T>;
        items.assignAll(data.results);
        count.value = data.count;
      } else if (result is Fail) {
        // A page past the end (after deletes/filters) falls back to page 1.
        if (result.code == 404 && page.value > 1) {
          load(toPage: 1);
          return;
        }
        showErrorSnack(result.message);
      }
    });
  }

  void setSearch(String value) {
    search.value = value.trim();
    _debouncer.run(() => load(toPage: 1));
  }

  void setFilter(String key, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      filters.remove(key);
    } else {
      filters[key] = value;
    }
    load(toPage: 1);
  }

  void setOrdering(String? value) {
    ordering.value = value;
    load(toPage: 1);
  }

  /// Replaces one row after an action, without reloading the page.
  void replaceWhere(bool Function(T) test, T item) {
    final i = items.indexWhere(test);
    if (i >= 0) items[i] = item;
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }
}
