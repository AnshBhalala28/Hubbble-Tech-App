class GetLikeModal {
  int? status;
  String? message;
  List<Data>? data;

  GetLikeModal({this.status, this.message, this.data});

  GetLikeModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? businessId;
  int? isLike;
  double? distanceToBusiness;
  Business? business;
  UserDetails? userDetails;

  Data(
      {this.businessId,
      this.isLike,
      this.distanceToBusiness,
      this.business,
      this.userDetails});

  Data.fromJson(Map<String, dynamic> json) {
    businessId = json['business_id'];
    isLike = json['is_like'];
    distanceToBusiness = json['distance_to_business'];
    business = json['business'] != null
        ? new Business.fromJson(json['business'])
        : null;
    userDetails = json['user_details'] != null
        ? new UserDetails.fromJson(json['user_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['business_id'] = this.businessId;
    data['is_like'] = this.isLike;
    data['distance_to_business'] = this.distanceToBusiness;
    if (this.business != null) {
      data['business'] = this.business!.toJson();
    }
    if (this.userDetails != null) {
      data['user_details'] = this.userDetails!.toJson();
    }
    return data;
  }
}

class Business {
  int? id;
  String? businessName;
  String? logo;
  String? subStatus;
  String? industry;

  Business(
      {this.id, this.businessName, this.logo, this.subStatus, this.industry});

  Business.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    businessName = json['business_name'];
    logo = json['logo'];
    subStatus = json['sub_status'];
    industry = json['industry'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['business_name'] = this.businessName;
    data['logo'] = this.logo;
    data['sub_status'] = this.subStatus;
    data['industry'] = this.industry;
    return data;
  }
}

class UserDetails {
  int? id;
  String? name;
  String? email;
  String? status;

  UserDetails({this.id, this.name, this.email, this.status});

  UserDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['status'] = this.status;
    return data;
  }
}
