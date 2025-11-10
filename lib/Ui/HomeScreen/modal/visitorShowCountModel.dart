class VisitorShowCountModel {
  int? status;
  String? message;
  int? data;

  VisitorShowCountModel({this.status, this.message, this.data});

  VisitorShowCountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    data['data'] = this.data;
    return data;
  }
}
