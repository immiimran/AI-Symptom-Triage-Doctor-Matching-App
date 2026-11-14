/// The user's profile details, saved on the device.
class UserProfile {
  const UserProfile({
    this.name = '',
    this.phone = '',
    this.age,
    this.gender = '',
    this.bloodGroup = '',
    this.photoFile = '',
  });

  final String name;
  final String phone;
  final int? age;

  /// 'male', 'female', 'other' or empty.
  final String gender;
  final String bloodGroup;

  /// File name of the profile photo inside the app documents folder.
  final String photoFile;

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'age': age,
    'gender': gender,
    'blood_group': bloodGroup,
    'photo_file': photoFile,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      age: (json['age'] as num?)?.toInt(),
      gender: (json['gender'] as String?) ?? '',
      bloodGroup: (json['blood_group'] as String?) ?? '',
      photoFile: (json['photo_file'] as String?) ?? '',
    );
  }
}
