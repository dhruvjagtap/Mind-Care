// presentation/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/booking_model.dart';
import '../data/slots_model.dart';
import './booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  static const routeName = '/booking';
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  Counselor? _selectedCounselor;
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counselorsAsync = ref.watch(counselorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Counsellor')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1) Counselor dropdown
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Counsellor', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            counselorsAsync.when(
              data: (list) => DropdownButtonFormField<Counselor>(
                value: _selectedCounselor,
                hint: const Text('Select counsellor'),
                items: list
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCounselor = c),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),

            // 2) Date picker
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      hintText:
                          '${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}',
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDay,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDay = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Optional note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3) Slots list
            Expanded(
              child: _selectedCounselor == null
                  ? Center(
                      child: Text(
                        'Select a counsellor to view available slots',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : Consumer(
                      builder: (context, ref, _) {
                        final slotsAsync = ref.watch(
                          availableSlotsProvider(
                            SlotsQuery(_selectedCounselor!.id, _selectedDay),
                          ),
                        );
                        return slotsAsync.when(
                          data: (slots) {
                            if (slots.isEmpty) {
                              return const Center(
                                child: Text('No slots for this day'),
                              );
                            }
                            return ListView.separated(
                              itemCount: slots.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final s = slots[i];
                                final time =
                                    '${_two(s.startAt.hour)}:${_two(s.startAt.minute)} - ${_two(s.endAt.hour)}:${_two(s.endAt.minute)}';
                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: theme.colorScheme.primary
                                          .withOpacity(.2),
                                    ),
                                  ),
                                  title: Text(time),
                                  subtitle: Text(_selectedCounselor!.name),
                                  trailing: ElevatedButton(
                                    onPressed: () => _bookSlot(s),
                                    child: const Text('Book'),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  Future<void> _bookSlot(Slot slot) async {
    final repo = ref.read(bookingRepoProvider);
    ref.read(bookingActionProvider.notifier).state = const AsyncLoading();

    try {
      await repo.bookSlot(
        slotId: slot.id,
        counselorId: slot.counselorId,
        note: _noteCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booked successfully')));
      }
      ref.read(bookingActionProvider.notifier).state = const AsyncData(null);
    } catch (e) {
      ref.read(bookingActionProvider.notifier).state = AsyncError(
        e,
        StackTrace.current,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    }
  }
}
