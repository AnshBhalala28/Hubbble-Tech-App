class ResidentAppUserprofileModel {
  int? status;
  String? message;
  Data? data;

  ResidentAppUserprofileModel({this.status, this.message, this.data});

  ResidentAppUserprofileModel.fromJson(Map<String, dynamic> json) {
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
  int? userId;
  int? createId;
  int? unitsId;
  String? residentType;
  String? createdAt;
  String? updatedAt;
  User? user;
  Unit? unit;
  Building? building;
  BuildingDocument? buildingDocument;

  Data(
      {this.id,
      this.userId,
      this.createId,
      this.unitsId,
      this.residentType,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.unit,
      this.building,
      this.buildingDocument});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    createId = json['create_id'];
    unitsId = json['units_id'];
    residentType = json['resident_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    unit = json['unit'] != null ? new Unit.fromJson(json['unit']) : null;
    building = json['building'] != null
        ? new Building.fromJson(json['building'])
        : null;
    buildingDocument = json['building_document'] != null
        ? new BuildingDocument.fromJson(json['building_document'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['create_id'] = this.createId;
    data['units_id'] = this.unitsId;
    data['resident_type'] = this.residentType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.unit != null) {
      data['unit'] = this.unit!.toJson();
    }
    if (this.building != null) {
      data['building'] = this.building!.toJson();
    }
    if (this.buildingDocument != null) {
      data['building_document'] = this.buildingDocument!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  int? role;
  Name? name;
  String? email;
  String? emailVerifiedAt;
  String? dPassword;
  int? mobileNo;
  String? gender;
  String? dateOfBirth;
  Address? address;
  String? psLatitude;
  String? psLongitude;
  String? fcmToken;
  String? forgetPassKey;
  String? moduleLock;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.role,
      this.name,
      this.email,
      this.emailVerifiedAt,
      this.dPassword,
      this.mobileNo,
      this.gender,
      this.dateOfBirth,
      this.address,
      this.psLatitude,
      this.psLongitude,
      this.fcmToken,
      this.forgetPassKey,
      this.moduleLock,
      this.status,
      this.profile,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'] != null ? new Name.fromJson(json['name']) : null;
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    psLatitude = json['ps_latitude'];
    psLongitude = json['ps_longitude'];
    fcmToken = json['fcm_token'];
    forgetPassKey = json['forget_pass_key'];
    moduleLock = json['module_lock'];
    status = json['status'];
    profile = json['profile'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    if (this.name != null) {
      data['name'] = this.name!.toJson();
    }
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['d_password'] = this.dPassword;
    data['mobile_no'] = this.mobileNo;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['ps_latitude'] = this.psLatitude;
    data['ps_longitude'] = this.psLongitude;
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    return data;
  }
}

class Unit {
  int? id;
  int? buildingId;
  int? userId;
  String? blockNumber;
  String? flatNumber;
  int? noOfKeys;
  String? keysOut;
  String? parkingOption;
  List<String>? documentsFiles;
  List<String>? documentsFilesLabel;
  String? keyWaiver;
  String? lettingAgentInfo;
  String? bicycleScooterInfo;
  String? createdAt;
  String? updatedAt;

  Unit(
      {this.id,
      this.buildingId,
      this.userId,
      this.blockNumber,
      this.flatNumber,
      this.noOfKeys,
      this.keysOut,
      this.parkingOption,
      this.documentsFiles,
      this.documentsFilesLabel,
      this.keyWaiver,
      this.lettingAgentInfo,
      this.bicycleScooterInfo,
      this.createdAt,
      this.updatedAt});

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    buildingId = json['building_id'];
    userId = json['user_id'];
    blockNumber = json['block_number'];
    flatNumber = json['flat_number'];
    noOfKeys = json['no_of_keys'];
    keysOut = json['keys_out'];
    parkingOption = json['parking_option'];
    documentsFiles = json['documents_files'].cast<String>();
    documentsFilesLabel = json['documents_files_label'].cast<String>();
    keyWaiver = json['key_waiver'];
    lettingAgentInfo = json['letting_agent_info'];
    bicycleScooterInfo = json['bicycle_scooter_info'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['building_id'] = this.buildingId;
    data['user_id'] = this.userId;
    data['block_number'] = this.blockNumber;
    data['flat_number'] = this.flatNumber;
    data['no_of_keys'] = this.noOfKeys;
    data['keys_out'] = this.keysOut;
    data['parking_option'] = this.parkingOption;
    data['documents_files'] = this.documentsFiles;
    data['documents_files_label'] = this.documentsFilesLabel;
    data['key_waiver'] = this.keyWaiver;
    data['letting_agent_info'] = this.lettingAgentInfo;
    data['bicycle_scooter_info'] = this.bicycleScooterInfo;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Building {
  int? id;
  int? userId;
  int? buildingId;
  String? companyName;
  String? personName;
  String? landline;
  String? mobile;
  String? buildingImage;
  String? createdAt;
  String? updatedAt;

  Building(
      {this.id,
      this.userId,
      this.buildingId,
      this.companyName,
      this.personName,
      this.landline,
      this.mobile,
      this.buildingImage,
      this.createdAt,
      this.updatedAt});

  Building.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    companyName = json['company_name'];
    personName = json['person_name'];
    landline = json['landline'];
    mobile = json['mobile'];
    buildingImage = json['Building_Image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_id'] = this.buildingId;
    data['company_name'] = this.companyName;
    data['person_name'] = this.personName;
    data['landline'] = this.landline;
    data['mobile'] = this.mobile;
    data['Building_Image'] = this.buildingImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class BuildingDocument {
  int? id;
  int? userId;
  String? buildingName;
  String? address;
  int? totalFloors;
  int? totalUnits;
  String? shiftStart;
  String? shiftEnd;
  String? loyaltyCardImage;
  List<String>? emergencyNumbers;
  List<String>? emergencyCaptions;
  String? parkingInformation;
  String? conciergeInformation;
  String? fitnessCentreInformation;
  List<String>? documentsFiles;
  String? conStartTime;
  String? conEndTime;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<String>? documentsFilesLabel;

  BuildingDocument(
      {this.id,
      this.userId,
      this.buildingName,
      this.address,
      this.totalFloors,
      this.totalUnits,
      this.shiftStart,
      this.shiftEnd,
      this.loyaltyCardImage,
      this.emergencyNumbers,
      this.emergencyCaptions,
      this.parkingInformation,
      this.conciergeInformation,
      this.fitnessCentreInformation,
      this.documentsFiles,
      this.conStartTime,
      this.conEndTime,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.documentsFilesLabel});

  BuildingDocument.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingName = json['building_name'];
    address = json['address'];
    totalFloors = json['total_floors'];
    totalUnits = json['total_units'];
    shiftStart = json['shift_start'];
    shiftEnd = json['shift_end'];
    loyaltyCardImage = json['loyalty_card_image'];
    emergencyNumbers = json['emergency_numbers'].cast<String>();
    emergencyCaptions = json['emergency_captions'].cast<String>();
    parkingInformation = json['parking_information'];
    conciergeInformation = json['concierge_information'];
    fitnessCentreInformation = json['fitness_centre_information'];
    documentsFiles = json['documents_files'].cast<String>();
    conStartTime = json['con_start_time'];
    conEndTime = json['con_end_time'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    documentsFilesLabel = json['documents_files_label'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_name'] = this.buildingName;
    data['address'] = this.address;
    data['total_floors'] = this.totalFloors;
    data['total_units'] = this.totalUnits;
    data['shift_start'] = this.shiftStart;
    data['shift_end'] = this.shiftEnd;
    data['loyalty_card_image'] = this.loyaltyCardImage;
    data['emergency_numbers'] = this.emergencyNumbers;
    data['emergency_captions'] = this.emergencyCaptions;
    data['parking_information'] = this.parkingInformation;
    data['concierge_information'] = this.conciergeInformation;
    data['fitness_centre_information'] = this.fitnessCentreInformation;
    data['documents_files'] = this.documentsFiles;
    data['con_start_time'] = this.conStartTime;
    data['con_end_time'] = this.conEndTime;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['documents_files_label'] = this.documentsFilesLabel;
    return data;
  }
}
