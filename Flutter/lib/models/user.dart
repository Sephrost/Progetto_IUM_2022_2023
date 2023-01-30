class User {
  String imagePath;
  String? nickName;
  String fullName;
  String email;
  String address;
  String phone;

  User({
    required this.imagePath,
    this.nickName,
    required this.fullName,
    required this.email,
    required this.address,
    required this.phone,
  });
}

/// Constructor used to create a user from a json file.
User fromJson(Map<String, dynamic> json) => User(
      imagePath: json['imagePath'],
      nickName: json['nickName'],
      fullName: json['fullName'],
      email: json['email'],
      address: json['address'],
      phone: json['phone'],
    );

/// Constructor used to create a json file from a user.
Map<String, dynamic> toJson(User user) => {
      'imagePath': user.imagePath,
      'nickName': user.nickName,
      'fullName': user.fullName,
      'email': user.email,
      'address': user.address,
      'phone': user.phone,
    };

class EmptyUser extends User {
  EmptyUser()
      : super(
          imagePath: '',
          nickName: '',
          fullName: '',
          email: '',
          address: '',
          phone: '',
        );
}
