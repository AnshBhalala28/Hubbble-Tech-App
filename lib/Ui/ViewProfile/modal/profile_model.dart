// import 'dart:convert';
//
// class ProfileModel {
//   int? status;
//   String? message;
//   Data? data;
//
//   ProfileModel({this.status, this.message, this.data});
//
//   ProfileModel.fromJson(Map<String, dynamic> json) {
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
//
// class Data {
//   int? id;
//   int? userId;
//   int? createId;
//   int? unitsId;
//   String? residentType;
//   String? createdAt;
//   String? updatedAt;
//   User? user;
//   Unit? unit;
//   Building? building;
//   BuildingDocument? buildingDocument;
//
//   Data({
//     this.id,
//     this.userId,
//     this.createId,
//     this.unitsId,
//     this.residentType,
//     this.createdAt,
//     this.updatedAt,
//     this.user,
//     this.unit,
//     this.building,
//     this.buildingDocument,
//   });
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     createId = json['create_id'];
//     unitsId = json['units_id'];
//     residentType = json['resident_type'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     user = json['user'] != null ? User.fromJson(json['user']) : null;
//     unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
//     building =
//         json['building'] != null ? Building.fromJson(json['building']) : null;
//     buildingDocument =
//         json['building_document'] != null
//             ? BuildingDocument.fromJson(json['building_document'])
//             : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['create_id'] = this.createId;
//     data['units_id'] = this.unitsId;
//     data['resident_type'] = this.residentType;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     if (this.user != null) {
//       data['user'] = this.user!.toJson();
//     }
//     if (this.unit != null) {
//       data['unit'] = this.unit!.toJson();
//     }
//     if (this.building != null) {
//       data['building'] = this.building!.toJson();
//     }
//     if (this.buildingDocument != null) {
//       data['building_document'] = this.buildingDocument!.toJson();
//     }
//     return data;
//   }
// }
//
// class User {
//   int? id;
//   int? role;
//   Name? name;
//   String? email;
//   String? emailVerifiedAt;
//   String? dPassword;
//   var mobileNo;
//   String? gender;
//   String? dateOfBirth;
//   Address? address;
//   String? fcmToken;
//   String? forgetPassKey;
//   String? moduleLock;
//   String? status;
//   String? profile;
//   String? fullName;
//   String? createdAt;
//   String? updatedAt;
//
//   User({
//     this.id,
//     this.role,
//     this.name,
//     this.email,
//     this.emailVerifiedAt,
//     this.dPassword,
//     this.mobileNo,
//     this.gender,
//     this.dateOfBirth,
//     this.address,
//     this.fcmToken,
//     this.forgetPassKey,
//     this.moduleLock,
//     this.status,
//     this.profile,
//     this.createdAt,
//     this.updatedAt,
//     this.fullName,
//   });
//
//   User.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     role = json['role'];
//     name = json['name'] != null ? Name.fromJson(json['name']) : null;
//     email = json['email'];
//     emailVerifiedAt = json['email_verified_at'];
//     dPassword = json['d_password'];
//     mobileNo = json['mobile_no'];
//     gender = json['gender'];
//     dateOfBirth = json['date_of_birth'];
//     address =
//         json['address'] != null ? Address.fromJson(json['address']) : null;
//     fcmToken = json['fcm_token'];
//     forgetPassKey = json['forget_pass_key'];
//     moduleLock = json['module_lock'];
//     status = json['status'];
//     profile = json['profile'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     fullName = json['full_name'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['role'] = this.role;
//     if (this.name != null) {
//       data['name'] = this.name!.toJson();
//     }
//     data['email'] = this.email;
//     data['email_verified_at'] = this.emailVerifiedAt;
//     data['d_password'] = this.dPassword;
//     data['mobile_no'] = this.mobileNo;
//     data['gender'] = this.gender;
//     data['date_of_birth'] = this.dateOfBirth;
//     if (this.address != null) {
//       data['address'] = this.address!.toJson();
//     }
//     data['fcm_token'] = this.fcmToken;
//     data['forget_pass_key'] = this.forgetPassKey;
//     data['module_lock'] = this.moduleLock;
//     data['status'] = this.status;
//     data['profile'] = this.profile;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     data['full_name'] = this.fullName;
//     return data;
//   }
// }
//
// class Name {
//   String? firstName;
//   String? lastName;
//
//   Name({this.firstName, this.lastName});
//
//   Name.fromJson(Map<String, dynamic> json) {
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['first_name'] = this.firstName;
//     data['last_name'] = this.lastName;
//     return data;
//   }
// }
//
// class Address {
//   String? address;
//   String? city;
//   String? country;
//   String? zipCode;
//
//   Address({this.address, this.city, this.country, this.zipCode});
//
//   Address.fromJson(Map<String, dynamic> json) {
//     address = json['address'];
//     city = json['city'];
//     country = json['country'];
//     zipCode = json['zip_code'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['address'] = this.address;
//     data['city'] = this.city;
//     data['country'] = this.country;
//     data['zip_code'] = this.zipCode;
//     return data;
//   }
// }
//
// class Unit {
//   int? id;
//   String? buildingId;
//   int? userId;
//   String? blockNumber;
//   String? flatNumber;
//   int? noOfKeys;
//   String? keysOut;
//   String? parkingOption;
//   List<String>? documentsFiles;
//   List<String>? documentsFilesLabel;
//   String? keyWaiver;
//   String? lettingAgentInfo;
//   String? bicycleScooterInfo;
//   String? createdAt;
//   String? updatedAt;
//
//   Unit({
//     this.id,
//     this.buildingId,
//     this.userId,
//     this.blockNumber,
//     this.flatNumber,
//     this.noOfKeys,
//     this.keysOut,
//     this.parkingOption,
//     this.documentsFiles,
//     this.documentsFilesLabel,
//     this.keyWaiver,
//     this.lettingAgentInfo,
//     this.bicycleScooterInfo,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   Unit.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     buildingId = json['building_id'];
//     userId = json['user_id'];
//     blockNumber = json['block_number'];
//     flatNumber = json['flat_number'];
//     noOfKeys = json['no_of_keys'];
//     keysOut = json['keys_out'];
//     parkingOption = json['parking_option'];
//     documentsFiles = json['documents_files'].cast<String>();
//     documentsFilesLabel = json['documents_files_label'].cast<String>();
//     keyWaiver = json['key_waiver'];
//     lettingAgentInfo = json['letting_agent_info'];
//     bicycleScooterInfo = json['bicycle_scooter_info'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['building_id'] = this.buildingId;
//     data['user_id'] = this.userId;
//     data['block_number'] = this.blockNumber;
//     data['flat_number'] = this.flatNumber;
//     data['no_of_keys'] = this.noOfKeys;
//     data['keys_out'] = this.keysOut;
//     data['parking_option'] = this.parkingOption;
//     data['documents_files'] = this.documentsFiles;
//     data['documents_files_label'] = this.documentsFilesLabel;
//     data['key_waiver'] = this.keyWaiver;
//     data['letting_agent_info'] = this.lettingAgentInfo;
//     data['bicycle_scooter_info'] = this.bicycleScooterInfo;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class Building {
//   int? id;
//   int? userId;
//   int? buildingId;
//   String? companyName;
//   String? personName;
//   String? landline;
//   String? mobile;
//   List<String>? buildingImage;
//   String? createdAt;
//   String? updatedAt;
//
//   Building({
//     this.id,
//     this.userId,
//     this.buildingId,
//     this.companyName,
//     this.personName,
//     this.landline,
//     this.mobile,
//     this.buildingImage,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   Building.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     buildingId = json['building_id'];
//     companyName = json['company_name'];
//     personName = json['person_name'];
//     landline = json['landline'];
//     mobile = json['mobile'];
//
//     if (json['Building_Image'] != null) {
//       try {
//         buildingImage = List<String>.from(jsonDecode(json['Building_Image']));
//       } catch (e) {
//         buildingImage = [];
//       }
//     }
//
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['building_id'] = this.buildingId;
//     data['company_name'] = this.companyName;
//     data['person_name'] = this.personName;
//     data['landline'] = this.landline;
//     data['mobile'] = this.mobile;
//     data['Building_Image'] = this.buildingImage;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
//
// class BuildingDocument {
//   int? id;
//   int? userId;
//   String? buildingName;
//   String? address;
//   int? totalFloors;
//   int? totalUnits;
//   String? shiftStart;
//   String? shiftEnd;
//   String? loyaltyCardImage;
//   List<String>? emergencyNumbers;
//   List<String>? emergencyCaptions;
//   String? parkingInformation;
//   String? conciergeInformation;
//   String? fitnessCentreInformation;
//   List<String>? documentsFiles;
//   String? conStartTime;
//   String? conEndTime;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//   List<String>? documentsFilesLabel;
//
//   BuildingDocument({
//     this.id,
//     this.userId,
//     this.buildingName,
//     this.address,
//     this.totalFloors,
//     this.totalUnits,
//     this.shiftStart,
//     this.shiftEnd,
//     this.loyaltyCardImage,
//     this.emergencyNumbers,
//     this.emergencyCaptions,
//     this.parkingInformation,
//     this.conciergeInformation,
//     this.fitnessCentreInformation,
//     this.documentsFiles,
//     this.conStartTime,
//     this.conEndTime,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.documentsFilesLabel,
//   });
//
//   BuildingDocument.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     buildingName = json['building_name'];
//     address = json['address'];
//     totalFloors = json['total_floors'];
//     totalUnits = json['total_units'];
//     shiftStart = json['shift_start'];
//     shiftEnd = json['shift_end'];
//     loyaltyCardImage = json['loyalty_card_image'];
//
//     emergencyNumbers =
//         (json['emergency_numbers'] is List)
//             ? List<String>.from(json['emergency_numbers'])
//             : [];
//
//     emergencyCaptions =
//         (json['emergency_captions'] is List)
//             ? List<String>.from(json['emergency_captions'])
//             : [];
//
//     documentsFiles =
//         (json['documents_files'] is List)
//             ? List<String>.from(json['documents_files'])
//             : [];
//
//     documentsFilesLabel =
//         (json['documents_files_label'] is List)
//             ? List<String>.from(json['documents_files_label'])
//             : [];
//
//     parkingInformation = json['parking_information'];
//     conciergeInformation = json['concierge_information'];
//     fitnessCentreInformation = json['fitness_centre_information'];
//     conStartTime = json['con_start_time'];
//     conEndTime = json['con_end_time'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['user_id'] = userId;
//     data['building_name'] = buildingName;
//     data['address'] = address;
//     data['total_floors'] = totalFloors;
//     data['total_units'] = totalUnits;
//     data['shift_start'] = shiftStart;
//     data['shift_end'] = shiftEnd;
//     data['loyalty_card_image'] = loyaltyCardImage;
//     data['emergency_numbers'] = emergencyNumbers;
//     data['emergency_captions'] = emergencyCaptions;
//     data['parking_information'] = parkingInformation;
//     data['concierge_information'] = conciergeInformation;
//     data['fitness_centre_information'] = fitnessCentreInformation;
//     data['documents_files'] = documentsFiles;
//     data['con_start_time'] = conStartTime;
//     data['con_end_time'] = conEndTime;
//     data['status'] = status;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     data['documents_files_label'] = documentsFilesLabel;
//     return data;
//   }
// }
import 'dart:convert';

/// ===== Helpers =====
List<String> _toStringList(dynamic v) {
  if (v == null) return [];
  if (v is List) {
    return v
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (v is String) {
    // Try JSON array text first
    try {
      final decoded = jsonDecode(v);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    // Fallback: comma-separated string
    return v
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [];
}

/// ===== Root Models =====

class ProfileModel {
  int? status;
  String? message;
  Data? data;

  ProfileModel({this.status, this.message, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    return map;
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

  Data({
    this.id,
    this.userId,
    this.createId,
    this.unitsId,
    this.residentType,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.unit,
    this.building,
    this.buildingDocument,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    createId = json['create_id'];
    unitsId = json['units_id'];
    residentType = json['resident_type']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
    building =
        json['building'] != null ? Building.fromJson(json['building']) : null;
    buildingDocument =
        json['building_document'] != null
            ? BuildingDocument.fromJson(json['building_document'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['create_id'] = createId;
    map['units_id'] = unitsId;
    map['resident_type'] = residentType;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (user != null) map['user'] = user!.toJson();
    if (unit != null) map['unit'] = unit!.toJson();
    if (building != null) map['building'] = building!.toJson();
    if (buildingDocument != null) {
      map['building_document'] = buildingDocument!.toJson();
    }
    return map;
  }
}

/// ===== User & Sub-objects =====

class User {
  int? id;
  int? role;
  Name? name;
  String? email;
  String? emailVerifiedAt;
  String? dPassword;
  String? mobileNo; // safer as String
  String? gender;
  String? dateOfBirth;
  Address? address;
  String? fcmToken;
  String? forgetPassKey;
  String? moduleLock;
  String? status;
  String? profile;
  String? fullName;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.role,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.dPassword,
    this.mobileNo,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.fcmToken,
    this.forgetPassKey,
    this.moduleLock,
    this.status,
    this.profile,
    this.createdAt,
    this.updatedAt,
    this.fullName,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    email = json['email']?.toString();
    emailVerifiedAt = json['email_verified_at']?.toString();
    dPassword = json['d_password']?.toString();
    mobileNo = json['mobile_no']?.toString();
    gender = json['gender']?.toString();
    dateOfBirth = json['date_of_birth']?.toString();
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    fcmToken = json['fcm_token']?.toString();
    forgetPassKey = json['forget_pass_key']?.toString();
    moduleLock = json['module_lock']?.toString();
    status = json['status']?.toString();
    profile = json['profile']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    fullName = json['full_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['role'] = role;
    if (name != null) map['name'] = name!.toJson();
    map['email'] = email;
    map['email_verified_at'] = emailVerifiedAt;
    map['d_password'] = dPassword;
    map['mobile_no'] = mobileNo;
    map['gender'] = gender;
    map['date_of_birth'] = dateOfBirth;
    if (address != null) map['address'] = address!.toJson();
    map['fcm_token'] = fcmToken;
    map['forget_pass_key'] = forgetPassKey;
    map['module_lock'] = moduleLock;
    map['status'] = status;
    map['profile'] = profile;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['full_name'] = fullName;
    return map;
  }
}

class Name {
  String? firstName;
  String? lastName;

  Name({this.firstName, this.lastName});

  Name.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    return map;
  }
}

class Address {
  String? address;
  String? city;
  String? country;
  String? zipCode; // safer as String

  Address({this.address, this.city, this.country, this.zipCode});

  Address.fromJson(Map<String, dynamic> json) {
    address = json['address']?.toString();
    city = json['city']?.toString();
    country = json['country']?.toString();
    zipCode = json['zip_code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['address'] = address;
    map['city'] = city;
    map['country'] = country;
    map['zip_code'] = zipCode;
    return map;
  }
}

/// ===== Unit =====

class Unit {
  var id;
var  buildingId; // store as String for flexibility
  var userId;
  var blockNumber;
  var flatNumber;
  var noOfKeys;
  var keysOut;
  var parkingOption;
  List<String>? documentsFiles;
  List<String>? documentsFilesLabel;
  var keyWaiver;
  var lettingAgentInfo;
  var bicycleScooterInfo;
  var createdAt;
  var updatedAt;

  Unit({
    this.id,
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
    this.updatedAt,
  });

  Unit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    buildingId = json['building_id']?.toString();
    userId = json['user_id'];
    blockNumber = json['block_number']?.toString();
    flatNumber = json['flat_number']?.toString();
    noOfKeys = json['no_of_keys'];
    keysOut = json['keys_out']?.toString();
    parkingOption = json['parking_option']?.toString();

    // Robust list parsing
    documentsFiles = _toStringList(json['documents_files']);
    documentsFilesLabel = _toStringList(json['documents_files_label']);

    keyWaiver = json['key_waiver']?.toString();
    lettingAgentInfo = json['letting_agent_info']?.toString();
    bicycleScooterInfo = json['bicycle_scooter_info']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['building_id'] = buildingId;
    map['user_id'] = userId;
    map['block_number'] = blockNumber;
    map['flat_number'] = flatNumber;
    map['no_of_keys'] = noOfKeys;
    map['keys_out'] = keysOut;
    map['parking_option'] = parkingOption;
    map['documents_files'] = documentsFiles;
    map['documents_files_label'] = documentsFilesLabel;
    map['key_waiver'] = keyWaiver;
    map['letting_agent_info'] = lettingAgentInfo;
    map['bicycle_scooter_info'] = bicycleScooterInfo;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

/// ===== Building =====

class Building {
  int? id;
  int? userId;
  int? buildingId;
  String? companyName;
  String? personName;
  String? landline;
  String? mobile;
  List<String>? buildingImage;
  String? createdAt;
  String? updatedAt;

  Building({
    this.id,
    this.userId,
    this.buildingId,
    this.companyName,
    this.personName,
    this.landline,
    this.mobile,
    this.buildingImage,
    this.createdAt,
    this.updatedAt,
  });

  Building.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    companyName = json['company_name']?.toString();
    personName = json['person_name']?.toString();
    landline = json['landline']?.toString();
    mobile = json['mobile']?.toString();

    // Can be null / JSON string / list / comma-separated
    buildingImage = _toStringList(json['Building_Image']);

    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['building_id'] = buildingId;
    map['company_name'] = companyName;
    map['person_name'] = personName;
    map['landline'] = landline;
    map['mobile'] = mobile;
    map['Building_Image'] = buildingImage;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

/// ===== Building Document =====

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

  BuildingDocument({
    this.id,
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
    this.documentsFilesLabel,
  });

  BuildingDocument.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingName = json['building_name']?.toString();
    address = json['address']?.toString();
    totalFloors = json['total_floors'];
    totalUnits = json['total_units'];
    shiftStart = json['shift_start']?.toString();
    shiftEnd = json['shift_end']?.toString();
    loyaltyCardImage = json['loyalty_card_image']?.toString();

    emergencyNumbers = _toStringList(json['emergency_numbers']);
    emergencyCaptions = _toStringList(json['emergency_captions']);
    documentsFiles = _toStringList(json['documents_files']);
    documentsFilesLabel = _toStringList(json['documents_files_label']);

    parkingInformation = json['parking_information']?.toString();
    conciergeInformation = json['concierge_information']?.toString();
    fitnessCentreInformation = json['fitness_centre_information']?.toString();
    conStartTime = json['con_start_time']?.toString();
    conEndTime = json['con_end_time']?.toString();
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['building_name'] = buildingName;
    map['address'] = address;
    map['total_floors'] = totalFloors;
    map['total_units'] = totalUnits;
    map['shift_start'] = shiftStart;
    map['shift_end'] = shiftEnd;
    map['loyalty_card_image'] = loyaltyCardImage;
    map['emergency_numbers'] = emergencyNumbers;
    map['emergency_captions'] = emergencyCaptions;
    map['parking_information'] = parkingInformation;
    map['concierge_information'] = conciergeInformation;
    map['fitness_centre_information'] = fitnessCentreInformation;
    map['documents_files'] = documentsFiles;
    map['con_start_time'] = conStartTime;
    map['con_end_time'] = conEndTime;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['documents_files_label'] = documentsFilesLabel;
    return map;
  }
}
