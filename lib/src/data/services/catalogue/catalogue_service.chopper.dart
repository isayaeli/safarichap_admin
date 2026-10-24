// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'catalogue_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CatalogueService extends CatalogueService {
  _$CatalogueService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CatalogueService;

  @override
  Future<Response<dynamic>> listItems(
    String resource,
    Map<String, dynamic> query,
  ) {
    final Uri $url = Uri.parse('/api/admin/${resource}/');
    final Map<String, dynamic> $params = query;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> retrieveItem(String resource, String uuid) {
    final Uri $url = Uri.parse('/api/admin/${resource}/${uuid}/');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> createItem(
    String resource,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/${resource}/');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> updateItem(
    String resource,
    String uuid,
    Map<String, dynamic> body,
  ) {
    final Uri $url = Uri.parse('/api/admin/${resource}/${uuid}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteItem(String resource, String uuid) {
    final Uri $url = Uri.parse('/api/admin/${resource}/${uuid}/');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> upload(String folder, MultipartFile file) {
    final Uri $url = Uri.parse('/api/admin/uploads/');
    final List<PartValue> $parts = <PartValue>[
      PartValue<String>('folder', folder),
      PartValueFile<MultipartFile>('file', file),
    ];
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      parts: $parts,
      multipart: true,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
