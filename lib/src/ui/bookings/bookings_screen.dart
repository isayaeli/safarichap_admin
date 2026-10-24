import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/paged_table.dart';
import 'package:safarichap_admin/src/core/components/status_chip.dart';
import 'package:safarichap_admin/src/core/utils/time_util.dart';
import 'package:safarichap_admin/src/data/models/booking/booking.dart';
import 'package:safarichap_admin/src/data/models/enums.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import 'booking_details_screen.dart';
import 'bookings_controller.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final _controller = Get.put(BookingsController(sl()));
  final ShellController _shell = Get.find();

  @override
  void dispose() {
    Get.delete<BookingsController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return Obx(
      () => PagedTable<AdminBooking>(
        controller: _controller,
        searchHint: 'Code, trip or customer',
        emptyMessage: 'No bookings match',
        onTap: (b) async {
          await _shell.open(BookingDetailsScreen(uuid: b.uuid));
          _controller.load();
        },
        filters: [
          FilterDropdown<String>(
            label: 'Status',
            value: _controller.filters['status'],
            options: {for (final s in BookingStatus.values) s.wire: s.label},
            onChanged: (v) => _controller.setFilter('status', v),
          ),
          FilterChip(
            label: Text("Upcoming only".tr),
            selected: _controller.filters['travel_date__gte'] != null,
            onSelected: (on) =>
                _controller.setFilter('travel_date__gte', on ? today : null),
          ),
        ],
        columns: [
          TableColumn(
            'Code',
            (b) => Text(
              b.confirmation_code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Trip',
            (b) => TwoLineCell(b.itinerary_title, b.operator_name),
            size: ColumnSize.L,
          ),
          TableColumn(
            'Customer',
            (b) => TwoLineCell(b.user.displayName, b.user.phone_number),
          ),
          TableColumn(
            'Travellers',
            (b) => Text('${b.travellers}'),
            numeric: true,
            size: ColumnSize.S,
          ),
          TableColumn(
            'Travel date',
            (b) => Text(TimeUtil.formatDate(b.travel_date)),
            sortKey: 'travel_date',
          ),
          TableColumn(
            'Status',
            (b) => StatusChip.booking(b.status),
            size: ColumnSize.S,
          ),
          TableColumn(
            'Booked',
            (b) => Text(TimeUtil.formatDate(b.created_at)),
            sortKey: 'created_at',
          ),
        ],
      ),
    );
  }
}
