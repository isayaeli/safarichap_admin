import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/utils/error_snack.dart';
import 'package:safarichap_admin/src/data/models/result.dart';
import 'package:safarichap_admin/src/data/repositories/catalogue_repository.dart';
import 'package:safarichap_admin/src/st/st.dart';

/// Lets the user pick a file and uploads it to `/api/admin/uploads/`.
/// Returns the public URL, or null if cancelled or failed.
Future<String?> pickAndUpload({
  required String folder,
  List<String> extensions = const ['jpg', 'jpeg', 'png', 'webp'],
}) async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: extensions,
  );
  final file = picked.firstOrNull;
  if (file == null) return null;
  if ((await file.length() ?? 0) > 10 * 1024 * 1024) {
    showErrorSnack("Files can be at most 10 MB.".tr);
    return null;
  }
  final bytes = await file.readAsBytes();
  final result = await sl<CatalogueRepository>().upload(
    folder: folder,
    bytes: bytes,
    filename: file.name,
  );
  if (result is Success<String>) return result.data;
  showErrorSnack((result as Fail).message);
  return null;
}
