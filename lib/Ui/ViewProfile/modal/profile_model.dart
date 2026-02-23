import 'dart:convert';

/// ===== Helpers =====

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

String? _toStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

List<String> _toStringList(dynamic v) {
  if (v == null) return [];
  if (v is List) {
    return v
        .map((e) => e?.toString() ?? '')
        .where((s) => s.trim().isNotEmpty)
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

    // Fallback comma-separated
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
    status = _toInt(json['status']);
    message = _toStr(json['message']);
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
    id = _toInt(json['id']);
    userId = _toInt(json['user_id']);
    createId = _toInt(json['create_id']);
    unitsId = _toInt(json['units_id']);
    residentType = _toStr(json['resident_type']);
    createdAt = _toStr(json['created_at']);
    updatedAt = _toStr(json['updated_at']);
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
    building = json['building'] != null ? Building.fromJson(json['building']) : null;
    buildingDocument = json['building_document'] != null
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
    if (buildingDocument != null) map['building_document'] = buildingDocument!.toJson();
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
  String? mobileNo;
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
    this.fullName,
    this.createdAt,
    this.updatedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    role = _toInt(json['role']);
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    email = _toStr(json['email']);
    emailVerifiedAt = _toStr(json['email_verified_at']);
    dPassword = _toStr(json['d_password']);
    mobileNo = _toStr(json['mobile_no']);
    gender = _toStr(json['gender']);
    dateOfBirth = _toStr(json['date_of_birth']);
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    fcmToken = _toStr(json['fcm_token']);
    forgetPassKey = _toStr(json['forget_pass_key']);
    moduleLock = _toStr(json['module_lock']);
    status = _toStr(json['status']);
    profile = _toStr(json['profile']);
    createdAt = _toStr(json['created_at']);
    updatedAt = _toStr(json['updated_at']);
    fullName = _toStr(json['full_name']);
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
    firstName = _toStr(json['first_name']);
    lastName = _toStr(json['last_name']);
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
  String? zipCode;

  Address({this.address, this.city, this.country, this.zipCode});

  Address.fromJson(Map<String, dynamic> json) {
    address = _toStr(json['address']);
    city = _toStr(json['city']);
    country = _toStr(json['country']);
    zipCode = _toStr(json['zip_code']);
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
  int? id;
  String? buildingId;
  int? userId;
  String? blockNumber;
  String? flatNumber;
  int? noOfKeys;
  String? keysOut;
  String? parkingOption;
  List<String> documentsFiles;
  List<String> documentsFilesLabel;
  String? keyWaiver;
  String? lettingAgentInfo;
  String? bicycleScooterInfo;
  String? createdAt;
  String? updatedAt;

  Unit({
    this.id,
    this.buildingId,
    this.userId,
    this.blockNumber,
    this.flatNumber,
    this.noOfKeys,
    this.keysOut,
    this.parkingOption,
    List<String>? documentsFiles,
    List<String>? documentsFilesLabel,
    this.keyWaiver,
    this.lettingAgentInfo,
    this.bicycleScooterInfo,
    this.createdAt,
    this.updatedAt,
  })  : documentsFiles = documentsFiles ?? <String>[],
        documentsFilesLabel = documentsFilesLabel ?? <String>[];

  Unit.fromJson(Map<String, dynamic> json)
      : id = _toInt(json['id']),
        buildingId = _toStr(json['building_id']),
        userId = _toInt(json['user_id']),
        blockNumber = _toStr(json['block_number']),
        flatNumber = _toStr(json['flat_number']),
        noOfKeys = _toInt(json['no_of_keys']),
        keysOut = _toStr(json['keys_out']),
        parkingOption = _toStr(json['parking_option']),
        documentsFiles = _toStringList(json['documents_files']),
        documentsFilesLabel = _toStringList(json['documents_files_label']),
        keyWaiver = _toStr(json['key_waiver']),
        lettingAgentInfo = _toStr(json['letting_agent_info']),
        bicycleScooterInfo = _toStr(json['bicycle_scooter_info']),
        createdAt = _toStr(json['created_at']),
        updatedAt = _toStr(json['updated_at']);

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
  List<String> buildingImage;
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
    List<String>? buildingImage,
    this.createdAt,
    this.updatedAt,
  }) : buildingImage = buildingImage ?? <String>[];

  Building.fromJson(Map<String, dynamic> json)
      : id = _toInt(json['id']),
        userId = _toInt(json['user_id']),
        buildingId = _toInt(json['building_id']),
        companyName = _toStr(json['company_name']),
        personName = _toStr(json['person_name']),
        landline = _toStr(json['landline']),
        mobile = _toStr(json['mobile']),
        buildingImage = _toStringList(json['Building_Image']),
        createdAt = _toStr(json['created_at']),
        updatedAt = _toStr(json['updated_at']);

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
  List<String> emergencyNumbers;
  List<String> emergencyCaptions;
  String? parkingInformation;
  String? conciergeInformation;
  String? fitnessCentreInformation;
  List<String> documentsFiles;
  String? conStartTime;
  String? conEndTime;
  String? status;
  String? createdAt;
  String? updatedAt;
  List<String> documentsFilesLabel;

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
    List<String>? emergencyNumbers,
    List<String>? emergencyCaptions,
    this.parkingInformation,
    this.conciergeInformation,
    this.fitnessCentreInformation,
    List<String>? documentsFiles,
    this.conStartTime,
    this.conEndTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    List<String>? documentsFilesLabel,
  })  : emergencyNumbers = emergencyNumbers ?? <String>[],
        emergencyCaptions = emergencyCaptions ?? <String>[],
        documentsFiles = documentsFiles ?? <String>[],
        documentsFilesLabel = documentsFilesLabel ?? <String>[];

  BuildingDocument.fromJson(Map<String, dynamic> json)
      : id = _toInt(json['id']),
        userId = _toInt(json['user_id']),
        buildingName = _toStr(json['building_name']),
        address = _toStr(json['address']),
        totalFloors = _toInt(json['total_floors']),
        totalUnits = _toInt(json['total_units']),
        shiftStart = _toStr(json['shift_start']),
        shiftEnd = _toStr(json['shift_end']),
        loyaltyCardImage = _toStr(json['loyalty_card_image']),
        emergencyNumbers = _toStringList(json['emergency_numbers']),
        emergencyCaptions = _toStringList(json['emergency_captions']),
        parkingInformation = _toStr(json['parking_information']),
        conciergeInformation = _toStr(json['concierge_information']),
        fitnessCentreInformation = _toStr(json['fitness_centre_information']),
        documentsFiles = _toStringList(json['documents_files']),
        conStartTime = _toStr(json['con_start_time']),
        conEndTime = _toStr(json['con_end_time']),
        status = _toStr(json['status']),
        createdAt = _toStr(json['created_at']),
        updatedAt = _toStr(json['updated_at']),
        documentsFilesLabel = _toStringList(json['documents_files_label']);

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