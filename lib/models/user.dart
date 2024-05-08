class User {
  final String name;
  final String email;
  final String? id;
  final String? imgUrl;
  final String? bio;

  User(
      {required this.name,
      required this.email,
      this.id,
      this.imgUrl,
      this.bio});
  Map<String, dynamic> toMap() {
    if (id == null) {
      return {
        "name": name,
        "email": email,
        "id": id,
        "imgUrl": imgUrl,
        "bio": bio,
      };
    }
    return {
      "name": name,
      "email": email,
      "id": id,
      "imgUrl": imgUrl,
      "bio": bio,
    };
  }
}
