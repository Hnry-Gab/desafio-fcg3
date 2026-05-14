import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/network/dio_client.dart';
import '../models/appointment_model.dart';
import '../models/resource_model.dart';
import '../../staff/models/scheduling_slot_model.dart';

class ResourceBookingService {
  final DioClient _client;

  ResourceBookingService({required DioClient client}) : _client = client;

  /// GET /resources — list available resources with optional type filter.
  Future<List<ClientResourceModel>> getAvailableResources({
    String? resourceType,
  }) async {
    final queryParams = <String, dynamic>{};
    if (resourceType != null) queryParams['resource_type'] = resourceType;
    final response = await _client.dio.get(
      '/resources',
      queryParameters: queryParams,
    );
    final data = response.data;
    final list = data is Map ? (data['data'] as List?) ?? [] : data as List;
    return list
        .map((e) => ClientResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /scheduling/slots?staff_id={resourceId} — get available slots for a resource.
  Future<List<SchedulingSlotModel>> getSlotsForResource(
    String resourceId,
  ) async {
    final response = await _client.dio.get(
      '/scheduling/slots',
      queryParameters: {'staff_id': resourceId},
    );
    final data = response.data;
    final list = data is Map ? (data['data'] as List?) ?? [] : data as List;
    return list
        .map((e) => SchedulingSlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /appointments — book a slot.
  Future<AppointmentModel> bookSlot({
    required String slotId,
    required String reason,
  }) async {
    final response = await _client.dio.post('/appointments', data: {
      'slot_id': slotId,
      'reason': reason,
    });
    return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /appointments/{id}/authorization — upload authorization file.
  ///
  /// Always uses [fileBytes] for cross-platform compatibility (web has no
  /// file-system access, so `MultipartFile.fromFile` would fail). The caller
  /// must pick files with `withData: true` so that bytes are loaded in memory.
  Future<void> uploadAuthorization({
    required String appointmentId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final contentType = _mimeTypeFromExtension(fileName);
    final multipartFile = MultipartFile.fromBytes(
      fileBytes,
      filename: fileName,
      contentType: contentType,
    );

    final formData = FormData.fromMap({'file': multipartFile});
    await _client.dio.post(
      '/appointments/$appointmentId/authorization',
      data: formData,
    );
  }

  /// Map common file extensions to MIME types accepted by the backend.
  static MediaType _mimeTypeFromExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return switch (ext) {
      'pdf' => MediaType('application', 'pdf'),
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      _ => MediaType('application', 'octet-stream'),
    };
  }

  /// PUT /appointments/{id}/cancel — cancel an appointment.
  Future<void> cancelAppointment(String appointmentId) async {
    await _client.dio.put('/appointments/$appointmentId/cancel');
  }
}
