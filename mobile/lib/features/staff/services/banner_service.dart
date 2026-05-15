import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/network/dio_client.dart';
import '../models/banner_model.dart';

/// API client for banner CRUD operations.
///
/// Endpoints:
///   GET  /banners/all   — staff/provider, returns ALL banners
///   POST /banners/upload — staff/provider, multipart file upload
///   PUT  /banners/{id}   — staff/provider, toggle enable/disable or reorder
///   DELETE /banners/{id}  — staff/provider, remove banner
class BannerService {
  final DioClient _client;

  BannerService({required DioClient client}) : _client = client;

  /// Fetch all banners (including disabled). Staff/provider only.
  Future<List<BannerModel>> fetchAll() async {
    final response = await _client.dio.get('/banners/all');
    final data = response.data;
    final list = data is Map ? (data['data'] as List?) ?? [] : data as List;
    return list
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Upload a new banner image. Returns the created BannerModel.
  Future<BannerModel> upload(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    final multipartFile = MultipartFile.fromBytes(
      bytes,
      filename: filename,
      contentType: MediaType.parse(mimeType),
    );
    final formData = FormData.fromMap({'file': multipartFile});
    final response = await _client.dio.post(
      '/banners/upload',
      data: formData,
    );
    return BannerModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Toggle banner enabled/disabled state.
  Future<BannerModel> toggleEnabled(String id, bool enabled) async {
    final response = await _client.dio.put(
      '/banners/$id',
      data: {'is_enabled': enabled},
    );
    return BannerModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update a banner's display order.
  Future<BannerModel> updateOrder(String id, int displayOrder) async {
    final response = await _client.dio.put(
      '/banners/$id',
      data: {'display_order': displayOrder},
    );
    return BannerModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete a banner permanently.
  Future<void> deleteBanner(String id) async {
    await _client.dio.delete('/banners/$id');
  }
}
