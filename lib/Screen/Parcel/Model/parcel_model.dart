class ParcelViewModal {
  int? status;
  String? message;
  Data? data;

  ParcelViewModal({this.status, this.message, this.data});

  ParcelViewModal.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  List<Data1>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  Null? prevPageUrl;
  int? to;
  int? total;

  Data({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  Data.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <Data1>[];
      json['data'].forEach((v) {
        data!.add(new Data1.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class Data1 {
  int? id;
  String? userId;
  int? requestId;
  int? receiverId;
  String? apartmentNo;
  int? noOfParcel;
  String? collectedBy;
  String? deliveredBy;
  Null? amount;
  String? comment;
  Null? trackingNumber;
  Null? courierService;
  String? deliveryStatus;
  Null? deletedAt;
  String? createdAt;
  String? updatedAt;
  Requester? requester;
  Unitsnumber? unitsnumber;

  Data1({
    this.id,
    this.userId,
    this.requestId,
    this.receiverId,
    this.apartmentNo,
    this.noOfParcel,
    this.collectedBy,
    this.deliveredBy,
    this.amount,
    this.comment,
    this.trackingNumber,
    this.courierService,
    this.deliveryStatus,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.requester,
    this.unitsnumber,
  });

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    requestId = json['request_id'];
    receiverId = json['receiver_id'];
    apartmentNo = json['apartment_no'];
    noOfParcel = json['no_of_parcel'];
    collectedBy = json['collected_by'];
    deliveredBy = json['delivered_by'];
    amount = json['amount'];
    comment = json['comment'];
    trackingNumber = json['tracking_number'];
    courierService = json['courier_service'];
    deliveryStatus = json['delivery_status'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    requester =
        json['requester'] != null
            ? new Requester.fromJson(json['requester'])
            : null;
    unitsnumber =
        json['unitsnumber'] != null
            ? new Unitsnumber.fromJson(json['unitsnumber'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['request_id'] = this.requestId;
    data['receiver_id'] = this.receiverId;
    data['apartment_no'] = this.apartmentNo;
    data['no_of_parcel'] = this.noOfParcel;
    data['collected_by'] = this.collectedBy;
    data['delivered_by'] = this.deliveredBy;
    data['amount'] = this.amount;
    data['comment'] = this.comment;
    data['tracking_number'] = this.trackingNumber;
    data['courier_service'] = this.courierService;
    data['delivery_status'] = this.deliveryStatus;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.requester != null) {
      data['requester'] = this.requester!.toJson();
    }
    if (this.unitsnumber != null) {
      data['unitsnumber'] = this.unitsnumber!.toJson();
    }
    return data;
  }
}

class Requester {
  int? id;
  int? role;
  String? name;
  String? email;
  Null? emailVerifiedAt;
  String? dPassword;
  int? mobileNo;
  String? gender;
  Null? dateOfBirth;
  Address? address;
  Null? psLatitude;
  Null? psLongitude;
  String? fcmToken;
  Null? forgetPassKey;
  Null? moduleLock;
  String? isOnline;
  Null? lastOnlineAt;
  String? status;
  String? profile;
  Null? deletedAt;
  String? createdAt;
  String? updatedAt;

  Requester({
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
    this.psLatitude,
    this.psLongitude,
    this.fcmToken,
    this.forgetPassKey,
    this.moduleLock,
    this.isOnline,
    this.lastOnlineAt,
    this.status,
    this.profile,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  Requester.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
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
    isOnline = json['is_online'];
    lastOnlineAt = json['last_online_at'];
    status = json['status'];
    profile = json['profile'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
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
    data['is_online'] = this.isOnline;
    data['last_online_at'] = this.lastOnlineAt;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
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

class Unitsnumber {
  int? id;
  Null? buildingId;
  int? userId;
  String? blockNumber;
  String? flatNumber;
  int? noOfKeys;
  Null? keysOut;
  String? parkingOption;
  List<String>? documentsFiles;
  List<String>? documentsFilesLabel;
  String? keyWaiver;
  String? lettingAgentInfo;
  String? bicycleScooterInfo;
  Null? deletedAt;
  String? createdAt;
  String? updatedAt;

  Unitsnumber({
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
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  Unitsnumber.fromJson(Map<String, dynamic> json) {
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
    deletedAt = json['deleted_at'];
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
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
