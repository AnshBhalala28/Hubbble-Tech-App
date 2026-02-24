class RemoveAmendModal {
  int? status;
  String? message;

  RemoveAmendModal({this.status, this.message});

  RemoveAmendModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    return data;
  }
}
