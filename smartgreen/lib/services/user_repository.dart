import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgreen/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<
    String?
  >
  getUserIdByEmail(
    String email,
  ) async {
    final query =
        await _firestore
            .collection(
              'Users',
            )
            .where(
              'email',
              isEqualTo:
                  email.trim(),
            )
            .limit(
              1,
            )
            .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  Future<
    void
  >
  updatePassword(
    String userId,
    String newPassword,
  ) async {
    final user = User.withMd5(
      name:
          '',
      email:
          '',
      password:
          newPassword.trim(),
    );
    await _firestore
        .collection(
          'Users',
        )
        .doc(
          userId,
        )
        .update(
          {
            'pass':
                user.password,
          },
        );
  }
}
