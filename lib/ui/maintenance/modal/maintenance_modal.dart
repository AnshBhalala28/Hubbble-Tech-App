// class MaintenanceModel {
//   int? status;
//   String? message;
//   List<Data>? data;

//   MaintenanceModel({this.status, this.message, this.data});

//   MaintenanceModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Data {
//   int? id;
//   int? userId;
//   int? buildingId;
//   int? unitId;
//   String? subject;
//   String? date;
//   String? note;
//   String? status;
//   String? createdAt;
//   String? updatedAt;

//   Data(
//       {this.id,
//       this.userId,
//       this.buildingId,
//       this.unitId,
//       this.subject,
//       this.date,
//       this.note,
//       this.status,
//       this.createdAt,
//       this.updatedAt});

//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     buildingId = json['building_id'];
//     unitId = json['unit_id'];
//     subject = json['subject'];
//     date = json['date'];
//     note = json['note'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['building_id'] = this.buildingId;
//     data['unit_id'] = this.unitId;
//     data['subject'] = this.subject;
//     data['date'] = this.date;
//     data['note'] = this.note;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
// }
class MaintenanceModel {
  int? status;
  String? message;
  Data? data;

  MaintenanceModel({this.status, this.message, this.data});

  MaintenanceModel.fromJson(Map<String, dynamic> json) {
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
  int? currentPage;
  List<Data1>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  var nextPageUrl;
  String? path;
  int? perPage;
  var prevPageUrl;
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
        data!.add(Data1.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
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
    final Map<String, dynamic> data = <String, dynamic>{};
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
  int? userId;
  var buildingId;
  var unitId;
  String? subject;
  String? date;
  String? note;
  String? status;
  String? notiRead;
  var deletedAt;
  String? createdAt;
  String? updatedAt;

  Data1({
    this.id,
    this.userId,
    this.buildingId,
    this.unitId,
    this.subject,
    this.date,
    this.note,
    this.status,
    this.notiRead,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  Data1.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    buildingId = json['building_id'];
    unitId = json['unit_id'];
    subject = json['subject'];
    date = json['date'];
    note = json['note'];
    status = json['status'];
    notiRead = json['noti_read'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['building_id'] = this.buildingId;
    data['unit_id'] = this.unitId;
    data['subject'] = this.subject;
    data['date'] = this.date;
    data['note'] = this.note;
    data['status'] = this.status;
    data['noti_read'] = this.notiRead;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
