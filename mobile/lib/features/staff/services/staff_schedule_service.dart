import '../../../core/network/dio_client.dart';
import '../../client/models/appointment_model.dart';
import '../models/scheduling_slot_model.dart';

class StaffScheduleService {
  final DioClient _client;

  StaffScheduleService({required DioClient client}) : _client = client;

  /// GET /appointments?status={status}
  Future<List<AppointmentModel>> getAppointments({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    final response = await _client.dio.get(
      '/appointments',
      queryParameters: queryParams,
    );
    final data = response.data;
    final list = data is Map ? (data['data'] as List?) ?? [] : data as List;
    return list
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /scheduling/slots?date_from={from}&date_to={to}
  Future<List<SchedulingSlotModel>> getSlots({
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, dynamic>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    final response = await _client.dio.get(
      '/scheduling/slots',
      queryParameters: queryParams,
    );
    final data = response.data;
    final list = data is List ? data : (data['data'] as List?) ?? [];
    return list
        .map((e) => SchedulingSlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /scheduling/slots/all — all slots (available + booked) for staff
  Future<List<SchedulingSlotModel>> getAllSlots({
    String? dateFrom,
    String? dateTo,
    String? resourceId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;
    if (resourceId != null) queryParams['resource_id'] = resourceId;
    final response = await _client.dio.get(
      '/scheduling/slots/all',
      queryParameters: queryParams,
    );
    final data = response.data;
    final list = data is List ? data : (data['data'] as List?) ?? [];
    return list
        .map((e) => SchedulingSlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /scheduling/slots — create availability slots
  Future<void> createSlots({
    required String resourceId,
    required String date,
    required String startTime,
    required String endTime,
    required int slotDurationMinutes,
  }) async {
    await _client.dio.post('/scheduling/slots', data: {
      'resource_id': resourceId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'slot_duration_minutes': slotDurationMinutes,
    });
  }

  /// PUT /scheduling/slots/{id} — edit a free slot
  Future<void> updateSlot({
    required String slotId,
    String? date,
    String? startTime,
    String? endTime,
  }) async {
    final body = <String, dynamic>{};
    if (date != null) body['date'] = date;
    if (startTime != null) body['start_time'] = startTime;
    if (endTime != null) body['end_time'] = endTime;
    await _client.dio.put('/scheduling/slots/$slotId', data: body);
  }

  /// DELETE /scheduling/slots/{id} — delete a free slot
  Future<void> deleteSlot(String slotId) async {
    await _client.dio.delete('/scheduling/slots/$slotId');
  }

  /// DELETE /scheduling/slots/batch — batch delete slots by resource+date
  Future<Map<String, dynamic>> batchDeleteSlots({
    required String resourceId,
    required String date,
    bool onlyAvailable = true,
  }) async {
    final response = await _client.dio.delete(
      '/scheduling/slots/batch',
      data: {
        'resource_id': resourceId,
        'date': date,
        'only_available': onlyAvailable,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT /appointments/{id}/cancel
  Future<void> cancelAppointment(String appointmentId) async {
    await _client.dio.put('/appointments/$appointmentId/cancel');
  }

  /// PUT /appointments/{id}/confirm
  Future<void> confirmAppointment(String appointmentId) async {
    await _client.dio.put('/appointments/$appointmentId/confirm');
  }

  /// PUT /appointments/{id}/no-show
  Future<void> markNoShow(String appointmentId) async {
    await _client.dio.put('/appointments/$appointmentId/no-show');
  }
}
