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
//     data = json['data'] != null ? Data.fromJson(json['data']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }
class LoginModel {
  int? status;
  String? message;
  Data? data;
  Map<String, dynamic>? validationErrors;

  LoginModel({this.status, this.message, this.data, this.validationErrors});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    // Check if response has validation errors (422 status)
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      if (json['data'].containsKey('email') ||
          json['data'].containsKey('password')) {
        // This is a validation error response
        validationErrors = json['data'];
        data = null;
      } else {
        // This is a successful response
        data = Data.fromJson(json['data']);
        validationErrors = null;
      }
    } else {
      data = null;
      validationErrors = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (this.validationErrors != null) {
      data['data'] = this.validationErrors;
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
  var mobileNo;
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
