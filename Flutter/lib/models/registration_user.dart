import 'package:flutter_app/models/user.dart';

class RegistrationUser extends User {
  final String password;

  RegistrationUser(
      {required String email,
      String? nickname,
      required this.password,
      required String imagePath,
      required String name,
      required String surname,
      required String address,
      required String phone})
      : super(
            email: email,
            nickName: nickname,
            imagePath: imagePath,
            fullName: "$name $surname",
            address: address,
            phone: phone);
}

toMap(RegistrationUser user) {
  return {
    'email': user.email,
    'password': user.password,
    'nickName': user.nickName,
    'imagePath': user.imagePath,
    'fullName': user.fullName,
    'address': user.address,
    'phone': user.phone
  };
}
