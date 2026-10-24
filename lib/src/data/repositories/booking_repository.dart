import 'package:safarichap_admin/src/core/utils/extensions.dart';
import 'package:safarichap_admin/src/data/admin_client.dart';
import 'package:safarichap_admin/src/data/models/booking/booking.dart';
import 'package:safarichap_admin/src/data/models/paginated.dart';
import '../models/result.dart';

class BookingRepository {
  final AdminClient _client;
  BookingRepository(this._client);

  Future<Result<Paginated<AdminBooking>>> retrieveBookings(
    Map<String, dynamic> query,
  ) async {
    final response = await _client.bookingsService().getBookings(
      cleanQuery(query),
    );
    return response.toResult(
      (body) => Paginated.fromJson(body, AdminBooking.fromJson),
    );
  }

  Future<Result<AdminBooking>> retrieveBooking(String uuid) async {
    final response = await _client.bookingsService().getBooking(uuid);
    return response.toResult(
      (body) => AdminBooking.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<AdminBooking>> updateStatus(String uuid, String status) async {
    final response = await _client.bookingsService().updateBooking(uuid, {
      'status': status,
    });
    return response.toResult(
      (body) => AdminBooking.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<TripDocument>> saveDocument({
    required String bookingUuid,
    String? documentUuid,
    required Map<String, dynamic> body,
  }) async {
    final service = _client.bookingsService();
    final response = documentUuid == null
        ? await service.addDocument(bookingUuid, body)
        : await service.updateDocument(documentUuid, body);
    return response.toResult(
      (body) => TripDocument.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<Result<void>> deleteDocument(String uuid) async {
    final response = await _client.bookingsService().deleteDocument(uuid);
    return response.toResult((_) {});
  }

  Future<Result<void>> notifyTraveller(String uuid) async {
    final response = await _client.bookingsService().notifyTraveller(uuid);
    return response.toResult((_) {});
  }
}
