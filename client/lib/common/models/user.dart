class User {
  final int id;
  String firstName;
  String lastName;
  String email;

  String get displayName => '$firstName $lastName';

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  User.fromJson(dynamic data)
    : id = data['id'],
      firstName = data['firstName'],
      lastName = data['lastName'],
      email = data['email'];
}
