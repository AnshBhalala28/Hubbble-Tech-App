// class LoginModel {
//   int? status;
//   String? message;
//   Data? data;
//
//   LoginModel({this.status, this.message, this.data});
//
//   LoginModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
//
// class Data {
//   User? user;
//   String? token;
//   Map<String, dynamic>? validationErrors;
//
//   Data({this.user, this.token, this.validationErrors});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     user = json['user'] != null ? User.fromJson(json['user']) : null;
//     token = json['token'];
//     validationErrors = json.containsKey('email') ? json : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     if (user != null) {
//       data['user'] = user!.toJson();
//     }
//     data['token'] = token;
//     data.addAll(validationErrors ?? {});
//     return data;
//   }
// }
//
// class User {
//   int? id;
//   int? role;
//   String? name;
//   String? email;
//   var emailVerifiedAt;
//   String? dPassword;
//   int? mobileNo;
//   String? gender;
//   String? address;
//   var fcmToken;
//   var forgetPassKey;
//   String? status;
//   String? profile;
//   String? createdAt;
//   String? updatedAt;
//
//   User(
//       {this.id,
//         this.role,
//         this.name,
//         this.email,
//         this.emailVerifiedAt,
//         this.dPassword,
//         this.mobileNo,
//         this.gender,
//         this.address,
//         this.fcmToken,
//         this.forgetPassKey,
//         this.status,
//         this.profile,
//         this.createdAt,
//         this.updatedAt});
//
//   User.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     role = json['role'];
//     name = json['name'];
//     email = json['email'];
//     emailVerifiedAt = json['email_verified_at'];
//     dPassword = json['d_password'];
//     mobileNo = json['mobile_no'];
//     gender = json['gender'];
//     address = json['address'];
//     fcmToken = json['fcm_token'];
//     forgetPassKey = json['forget_pass_key'];
//     status = json['status'];
//     profile = json['profile'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['role'] = this.role;
//     data['name'] = this.name;
//     data['email'] = this.email;
//     data['email_verified_at'] = this.emailVerifiedAt;
//     data['d_password'] = this.dPassword;
//     data['mobile_no'] = this.mobileNo;
//     data['gender'] = this.gender;
//     data['address'] = this.address;
//     data['fcm_token'] = this.fcmToken;
//     data['forget_pass_key'] = this.forgetPassKey;
//     data['status'] = this.status;
//     data['profile'] = this.profile;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
//
//
class LoginModel {
  int? status;
  String? message;
  Data? data;

  LoginModel({this.status, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  User? user;
  String? token;

  Data({this.user, this.token});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class User {
  int? id;
  int? role;
  Name? name;
  String? email;
  String? dPassword;
  int? mobileNo;
  String? gender;
  Address? address;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;
  String? fullName;

  User({
    this.id,
    this.role,
    this.name,
    this.email,
    this.dPassword,
    this.mobileNo,
    this.gender,
    this.address,
    this.status,
    this.profile,
    this.createdAt,
    this.updatedAt,
    this.fullName,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];

    // Handle `name` field properly
    if (json['name'] is Map<String, dynamic>) {
      name = Name.fromJson(json['name']);
    } else if (json['name'] is String) {
      name = Name(firstName: json['name'], lastName: "");
    } else {
      name = null;
    }

    email = json['email'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];

    // Handle `address` field properly
    if (json['address'] is Map<String, dynamic>) {
      address = Address.fromJson(json['address']);
    } else {
      address = null;
    }

    status = json['status'];
    profile = json['profile'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['role'] = role;

    if (name != null) {
      data['name'] = name!.toJson();
    }

    data['email'] = email;
    data['d_password'] = dPassword;
    data['mobile_no'] = mobileNo;
    data['gender'] = gender;

    if (address != null) {
      data['address'] = address!.toJson();
    }

    data['status'] = status;
    data['profile'] = profile;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['full_name'] = fullName;
    return data;
  }
}

class Name {
  String? firstName;
  String? lastName;

  Name({this.firstName, this.lastName});

  Name.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}

class Address {
  String? address;
  String? city;
  String? country;
  String? zipCode;

  Address({this.address, this.city, this.country, this.zipCode});

  Address.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    city = json['city'];
    country = json['country'];
    zipCode = json['zip_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    return data;
  }
}
