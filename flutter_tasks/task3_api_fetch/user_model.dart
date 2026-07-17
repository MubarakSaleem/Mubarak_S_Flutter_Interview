/// Model for a single user from https://jsonplaceholder.typicode.com/users
///
/// Keeping this as a proper class (instead of passing raw `Map<String, dynamic>`
/// around the UI) means:
///  - The UI gets compile-time safety (`user.name`, not `user['name']`
///    with a possible typo that only breaks at runtime).
///  - JSON-shape knowledge is isolated to one place (`fromJson`), so if the
///    API response shape changes, only this file needs updating.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String username;
  final String website;
  final String city; // nested inside `address` in the raw JSON

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.website,
    required this.city,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      username: json['username'] as String? ?? '',
      website: json['website'] as String? ?? '',
      city: address?['city'] as String? ?? '',
    );
  }
}
