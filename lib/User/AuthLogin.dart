// AuthLogin authLoginFromJson(String str) => AuthLogin.fromJson(json.decode(str));

// String authLoginToJson(AuthLogin data) => json.encode(data.toJson());

class AuthLogin {
  String message;
  Data data;

  AuthLogin({required this.data, required this.message});

  factory AuthLogin.fromJson(Map<String, dynamic> json) {
    return AuthLogin(
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }
}

class TokenAuth {
  String token;
  TokenAuth({required this.token});

  factory TokenAuth.fromJson(Map<String, dynamic> data) {
    return TokenAuth(token: data['token']);
  }
}

class Data {
  String id;
  String token;
  String name;
  String email;
  String role;
  String kelamin;
  String agama;
  String jabatan;
  String alamat;
  String image;

  Data({
    required this.id,
    required this.token,
    required this.name,
    required this.email,
    required this.role,
    required this.kelamin,
    required this.agama,
    required this.jabatan,
    required this.alamat,
    required this.image,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      token: json['token'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      kelamin: json['kelamin'],
      agama: json['agama'],
      jabatan: json['jabatan'],
      alamat: json['alamat'],
      image: json['image'],
    );
  }
}

class Logout {
  String message;
  Logout({required this.message});
  factory Logout.fromJson(Map<String, dynamic> json) {
    return Logout(message: json['message']);
  }
}
