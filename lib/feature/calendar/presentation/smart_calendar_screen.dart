import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'smart_calendar_provider.dart';
import '../data/smart_calendar_model.dart';
import '../../profile/presentation/profile_provider.dart';
import '../data/stress_tip_service.dart';

class SmartCalendarScreen extends ConsumerWidget {
  const SmartCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(calendarEventsProvider);
    final profile = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Calendar")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (profile.isEmpty) return;

          final titleController = TextEditingController();
          String selectedType = "exam";
          DateTime? selectedDate;

          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add New Event"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title input
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Event Title",
                      ),
                    ),

                    // Dropdown for type
                    DropdownButton<String>(
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: "exam", child: Text("Exam")),
                        DropdownMenuItem(
                          value: "submission",
                          child: Text("Submission"),
                        ),
                        DropdownMenuItem(
                          value: "reminder",
                          child: Text("Reminder"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          selectedType = value;
                        }
                      },
                    ),

                    // Date picker button
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          selectedDate = picked;
                        }
                      },
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty || selectedDate == null)
                        return;

                      final tip = StressTipService.generateTip(selectedType);

                      final newEvent = CalendarEvent(
                        id: '',
                        college: profile['college'],
                        prn: profile['prn'],
                        title: titleController.text,
                        date: selectedDate!,
                        type: selectedType,
                        stressTip: tip,
                      );

                      await ref
                          .read(smartCalendarRepositoryProvider)
                          .addEvent(newEvent);
                      Navigator.pop(context);
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text("Add Event", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 6,
      ),

      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text("No events yet!"));
          }
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                    "${event.type.toUpperCase()} • ${event.date.toLocal()}",
                  ),
                  trailing: event.stressTip != null
                      ? IconButton(
                          icon: const Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(event.stressTip!)),
                            );
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
