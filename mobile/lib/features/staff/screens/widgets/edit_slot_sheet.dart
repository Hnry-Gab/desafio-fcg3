import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scheduling_slot_model.dart';
import '../../providers/staff_schedule_provider.dart';

/// Shows the edit slot bottom sheet.
void showEditSlotSheet(
  BuildContext context,
  WidgetRef ref,
  SchedulingSlotModel slot,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _EditSlotSheet(slot: slot),
  );
}

class _EditSlotSheet extends ConsumerStatefulWidget {
  final SchedulingSlotModel slot;

  const _EditSlotSheet({required this.slot});

  @override
  ConsumerState<_EditSlotSheet> createState() => _EditSlotSheetState();
}

class _EditSlotSheetState extends ConsumerState<_EditSlotSheet> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing values
    final dateParts = widget.slot.date.split('-');
    if (dateParts.length == 3) {
      _selectedDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      _dateController.text =
          '${dateParts[2]}/${dateParts[1]}/${dateParts[0]}';
    }

    final startParts = widget.slot.startTime.split(':');
    if (startParts.length >= 2) {
      _selectedStartTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      _startTimeController.text = widget.slot.startTime;
    }

    final endParts = widget.slot.endTime.split(':');
    if (endParts.length >= 2) {
      _selectedEndTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
      _endTimeController.text = widget.slot.endTime;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
        _startTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? const TimeOfDay(hour: 17, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
        _endTimeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? dateStr;
      if (_selectedDate != null) {
        dateStr =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      }

      await ref.read(staffScheduleServiceProvider).updateSlot(
            slotId: widget.slot.id,
            date: dateStr,
            startTime: _startTimeController.text.isNotEmpty
                ? _startTimeController.text
                : null,
            endTime: _endTimeController.text.isNotEmpty
                ? _endTimeController.text
                : null,
          );
      ref.invalidate(staffAllSlotsProvider);
      ref.invalidate(staffSlotsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horario atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar horario. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 40,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Editar Horario',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.slot.staff?.name ?? 'Recurso',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                // Date field
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty
                          ? 'Selecione a data'
                          : null,
                ),
                const SizedBox(height: 16),
                // Start time field
                TextFormField(
                  controller: _startTimeController,
                  readOnly: true,
                  onTap: _pickStartTime,
                  decoration: const InputDecoration(
                    labelText: 'Horario de inicio',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Selecione o horario de inicio'
                      : null,
                ),
                const SizedBox(height: 16),
                // End time field
                TextFormField(
                  controller: _endTimeController,
                  readOnly: true,
                  onTap: _pickEndTime,
                  decoration: const InputDecoration(
                    labelText: 'Horario de termino',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Selecione o horario de termino'
                      : null,
                ),
                const SizedBox(height: 24),
                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar Alteracoes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
