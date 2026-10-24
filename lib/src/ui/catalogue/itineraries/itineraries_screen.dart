import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/permission_gate.dart';
import 'package:safarichap_admin/src/core/components/safari_image.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/money/money.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/data/models/catalogue/catalogue.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import '../catalogue_controller.dart';
import 'itinerary_form_screen.dart';

class ItinerariesScreen extends StatefulWidget {
  const ItinerariesScreen({super.key});

  @override
  State<ItinerariesScreen> createState() => _ItinerariesScreenState();
}

class _ItinerariesScreenState extends State<ItinerariesScreen> {
  final _controller = Get.put(
    CatalogueController<ItinerarySummary>(
      sl(),
      CatalogueRepository.itineraries,
      ItinerarySummary.fromJson,
    ),
    tag: CatalogueRepository.itineraries,
  );
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<CatalogueController<ItinerarySummary>>(
      tag: CatalogueRepository.itineraries,
    );
    super.dispose();
  }

  Future<void> _open([String? uuid]) async {
    await _shell.open(ItineraryFormScreen(uuid: uuid));
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PagedTable<ItinerarySummary>(
        controller: _controller,
        searchHint: 'Title, slug or operator',
        emptyMessage: 'No trips match',
        onTap: (i) => _open(i.uuid),
        filters: [
          FilterDropdown<String>(
            label: 'Visibility',
            value: _controller.filters['is_active'],
            options: {'true': 'Published'.tr, 'false': 'Hidden'.tr},
            onChanged: (v) => _controller.setFilter('is_active', v),
          ),
          FilterDropdown<String>(
            label: 'Featured',
            value: _controller.filters['is_featured'],
            options: {'true': 'Featured'.tr, 'false': 'Not featured'.tr},
            onChanged: (v) => _controller.setFilter('is_featured', v),
          ),
          FilterDropdown<String>(
            label: 'Accommodation',
            value: _controller.filters['accommodation_level'],
            options: {
              for (final a in AccommodationLevel.values) a.wire: a.label,
            },
            onChanged: (v) => _controller.setFilter('accommodation_level', v),
          ),
        ],
        actions: [
          PermissionGate(
            code: 'catalogue.manage',
            child: FilledButton.icon(
              onPressed: _open,
              icon: const Icon(Icons.add, size: 18),
              label: Text("New trip".tr),
            ),
          ),
        ],
        columns: [
          TableColumn(
            '',
            (i) => SafariImage(
              url: i.images.isEmpty ? null : i.images.first,
              width: 64,
              height: 42,
              borderRadius: BorderRadius.circular(6),
            ),
            fixedWidth: 88,
          ),
          TableColumn(
            'Trip',
            (i) => TwoLineCell(i.title, i.destinations.join(' · ')),
            size: ColumnSize.L,
            sortKey: 'title',
          ),
          TableColumn(
            'Operator',
            (i) => Text(i.operator_name, overflow: TextOverflow.ellipsis),
          ),
          TableColumn(
            'Days',
            (i) => Text('${i.duration_days}'),
            numeric: true,
            size: ColumnSize.S,
          ),
          TableColumn(
            'Level',
            (i) => Text(i.accommodation_level.label),
            size: ColumnSize.S,
          ),
          TableColumn(
            'From (resident adult)',
            (i) => Text(
              i.from_price == null || i.base_currency == null
                  ? '-'
                  : Money(
                      i.from_price!,
                      Currency.fromCode(i.base_currency!),
                    ).formatted,
            ),
            numeric: true,
          ),
          TableColumn(
            'Status',
            (i) => Wrap(
              spacing: 4,
              children: [
                StatusChip.active(
                  i.is_active,
                  on: 'Published'.tr,
                  off: 'Hidden'.tr,
                ),
                if (i.is_featured)
                  StatusChip(
                    label: "Featured".tr,
                    color: Colors.amber.shade800,
                  ),
              ],
            ),
          ),
          TableColumn(
            'Goals',
            (i) => Text('${i.goals_count}'),
            numeric: true,
            size: ColumnSize.S,
            sortKey: 'goals_count',
          ),
        ],
      ),
    );
  }
}
