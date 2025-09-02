import 'package:cloud_firestore/cloud_firestore.dart';
import 'resource_model.dart';

class ResourceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ResourceModel>> getResources() {
    return _firestore.collection('resources').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ResourceModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
