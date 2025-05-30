class UserPersonalInfoModel {
  int? status;
  String? message;
  Data? data;

  UserPersonalInfoModel({this.status, this.message, this.data});

  UserPersonalInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? userId;
  int? buildingId;
  int? gateId;
  String? email;
  String? firstName;
  String? lastName;
  String? gender;
  String? dateOfBirth;
  String? phoneNumber;
  String? conciergeImage;
  String? address;
  String? city;
  String? state;
  String? country;
  String? zipCode;
  String? shiftStart;
  String? shiftEnd;
  String? conStartTime;
  String? conEndTime;
  String? livestatus;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
      this.userId,
      this.buildingId,
      this.gateId,
      this.email,
      this.firstName,
      this.lastName,
      this.gender,
      this.dateOfBirth,
      this.phoneNumber,
      this.conciergeImage,
      this.address,
      this.city,
      this.state,
      this.country,
      this.zipCode,
      this.shiftStart,
      this.shiftEnd,
      this.conStartTime,
      this.conEndTime,
      this.livestatus,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    gateId = json['gate_id'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    phoneNumber = json['phone_number'];
    conciergeImage = json['concierge_image'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zipCode = json['zip_code'];
    shiftStart = json['shift_start'];
    shiftEnd = json['shift_end'];
    conStartTime = json['con_start_time'];
    conEndTime = json['con_end_time'];
    livestatus = json['livestatus'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_id'] = this.buildingId;
    data['gate_id'] = this.gateId;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    data['phone_number'] = this.phoneNumber;
    data['concierge_image'] = this.conciergeImage;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    data['shift_start'] = this.shiftStart;
    data['shift_end'] = this.shiftEnd;
    data['con_start_time'] = this.conStartTime;
    data['con_end_time'] = this.conEndTime;
    data['livestatus'] = this.livestatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
