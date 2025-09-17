// lib/feature/resources/presenetation/resources_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './resource_provider.dart';
import '../../analytics/analytics_service.dart';
import '../../profile/data/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  static const routeName = '/resources';
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final List<String> _categories = [
    'All',
    'Anxiety & Overthinking',
    'Counselling & Helpline Info',
    'Depression Awareness & Support',
    'Mindfulness & Meditation',
    'Self-Confidence & Personal Growth',
    'Sleep & Relaxation',
    'Study Motivation & Productivity',
  ];

  String _selectedCategory = 'All';

  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    analyticsService.logScreenView("ResourcesScreen");
  }

  @override
  void dispose() {
    final duration = DateTime.now().difference(_startTime);
    analyticsService.logEvent(
      "resources_screen_time",
      params: {"seconds": duration.inSeconds},
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resourcesAsync = ref.watch(resourcesProvider); // 👈 Riverpod usage

    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categories', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),

            // Category chips
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryChip(theme, category);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Resources list
            Expanded(
              child: resourcesAsync.when(
                data: (resources) {
                  final filtered = _selectedCategory == 'All'
                      ? resources
                      : resources
                            .where((r) => r.category == _selectedCategory)
                            .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No resources for $_selectedCategory",
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final res = filtered[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(res.title),
                          subtitle: Text(res.description),
                          trailing: Icon(
                            res.type == "video"
                                ? Icons.video_library
                                : res.type == "audio"
                                ? Icons.audiotrack
                                : Icons.picture_as_pdf,
                          ),
                          onTap: () async {
                            final profile = await ProfileService()
                                .getProfile(); // get prn + college
                            final prn = profile?['prn'];
                            final college = profile?['college'];

                            // log resource open in Firestore
                            await FirebaseFirestore.instance
                                .collection('resource_access')
                                .add({
                                  'prn': prn,
                                  'college': college,
                                  'resourceId': res.id,
                                  'resourceTitle': res.title,
                                  'resourceCategory': res.category,
                                  'resourceType': res.type,
                                  'accessedAt': FieldValue.serverTimestamp(),
                                  // optional: you can add durationSeconds later
                                });

                            // log resource open
                            analyticsService.logEvent(
                              "resource_opened",
                              params: {
                                "title": res.title,
                                "category": res.category,
                                "type": res.type,
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text("Error loading resources: $err")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, String category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedCategory = category);

        analyticsService.logEvent(
          "category_selected",
          params: {"category": category},
        );
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }
}
