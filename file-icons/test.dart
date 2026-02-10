import 'dart:async';
import 'dart:convert';

class User {
  final String name;
  final String email;
  final int age;

  User({required this.name, required this.email, required this.age});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      age: json['age'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'age': age,
      };

  @override
  String toString() => 'User($name, $email, age: $age)';
}

Future<void> main() async {
  final users = [
    User(name: 'Alice', email: 'alice@example.com', age: 30),
    User(name: 'Bob', email: 'bob@example.com', age: 25),
  ];

  final jsonString = jsonEncode(users.map((u) => u.toJson()).toList());
  print('Serialized: $jsonString');

  final decoded = (jsonDecode(jsonString) as List)
      .map((item) => User.fromJson(item))
      .toList();
  decoded.forEach(print);
}
