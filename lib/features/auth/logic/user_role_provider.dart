// lib/features/auth/logic/user_role_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class UserRoleNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final localBox = await Hive.openBox<String>('userRole');
    final localRole = localBox.get(user.uid);

    if (localRole != null) return localRole;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists || !doc.data()!.containsKey('role')) {
      throw Exception('Rol no definido');
    }

    final remoteRole = doc['role'] as String;
    await localBox.put(user.uid, remoteRole);
    return remoteRole;
  }

  Future<void> saveRole(String role) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final localBox = await Hive.openBox<String>('userRole');
    await localBox.put(user.uid, role);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'role': role,
    }, SetOptions(merge: true));

    state = AsyncValue.data(role);
  }
}

final userRoleProvider = AsyncNotifierProvider<UserRoleNotifier, String>(
  () => UserRoleNotifier(),
);
