class ChatShowCountModal {
  int? status;
  String? message;
  int? data;

  ChatShowCountModal({this.status, this.message, this.data});

  ChatShowCountModal.fromJson(Map<String, dynamic> json) {
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
