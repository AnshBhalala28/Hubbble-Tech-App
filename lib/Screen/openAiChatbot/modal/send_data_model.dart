class SendChatModal {
  int? status;
  String? message;
  String? reply;

  SendChatModal({this.status, this.message, this.reply});

  SendChatModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    reply = json['reply'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['message'] = this.message;
    data['reply'] = this.reply;
    return data;
  }
}
