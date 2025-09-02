import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/resource_service.dart';
import '../data/resource_model.dart';

// Provide ResourceService
final resourceServiceProvider = Provider<ResourceService>((ref) {
  return ResourceService();
});

// Provide resources stream (listens to Firestore changes)
final resourcesProvider = StreamProvider<List<ResourceModel>>((ref) {
  return ref.watch(resourceServiceProvider).getResources();
});
