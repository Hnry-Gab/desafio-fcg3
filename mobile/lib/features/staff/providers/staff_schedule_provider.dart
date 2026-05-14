import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/dio_provider.dart';
import '../../../core/providers/cache_provider.dart';
import '../../client/models/appointment_model.dart';
import '../models/scheduling_slot_model.dart';
import '../services/staff_schedule_service.dart';

part 'staff_schedule_provider.g.dart';

@Riverpod(keepAlive: true)
StaffScheduleService staffScheduleService(Ref ref) {
  final client = ref.watch(dioClientProvider);
  return StaffScheduleService(client: client);
}

@riverpod
Future<List<AppointmentModel>> staffAppointments(Ref ref) async {
  final service = ref.watch(staffScheduleServiceProvider);
  final appointments = await service.getAppointments();
  CacheTTL.schedule(ref, 'staffAppointments');
  return appointments;
}

@riverpod
Future<List<SchedulingSlotModel>> staffSlots(Ref ref) async {
  final service = ref.watch(staffScheduleServiceProvider);
  return service.getSlots();
}

/// Provider for ALL slots (available + booked) — used in staff "Horarios" tab
@riverpod
Future<List<SchedulingSlotModel>> staffAllSlots(Ref ref) async {
  final service = ref.watch(staffScheduleServiceProvider);
  final resourceId = ref.watch(staffSlotResourceFilterProvider);
  final slots = await service.getAllSlots(resourceId: resourceId);
  CacheTTL.schedule(ref, 'staffAllSlots');
  return slots;
}

@riverpod
class StaffScheduleFilter extends _$StaffScheduleFilter {
  @override
  String? build() => null; // null = "Todos"

  void setFilter(String? status) => state = status;
}

@riverpod
class StaffScheduleSearch extends _$StaffScheduleSearch {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

/// Filter for slots tab: resource ID
@riverpod
class StaffSlotResourceFilter extends _$StaffSlotResourceFilter {
  @override
  String? build() => null; // null = all resources

  void setResourceId(String? id) => state = id;
}

/// Search for slots tab
@riverpod
class StaffSlotSearch extends _$StaffSlotSearch {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}
