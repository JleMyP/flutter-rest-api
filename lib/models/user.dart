class User {
  final String username;
  final String firstName;
  final String lastName;
  final String middleName;
  final String email;
  final String phone;

  User({
    this.username,
    this.firstName,
    this.lastName,
    this.middleName,
    this.email,
    this.phone,
  });

  String get shortName {
    String short = '';
    if ((firstName ?? '').isNotEmpty && (lastName ?? '').isNotEmpty) {
      short = '$lastName ${firstName[0]}.';
      if ((middleName ?? '').isNotEmpty) {
        short += ' ${middleName[0]}.';
      }
      return short;
    }

    if ((lastName ?? '').isNotEmpty) {
      return lastName;
    }

    if ((firstName ?? '').isNotEmpty) {
      return firstName;
    }

    return username;
  }
}
