class ChatbotDataModal {
  int? status;
  List<Conversations>? conversations;

  ChatbotDataModal({this.status, this.conversations});

  ChatbotDataModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['conversations'] != null) {
      conversations = <Conversations>[];
      json['conversations'].forEach((v) {
        conversations!.add(new Conversations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.conversations != null) {
      data['conversations'] =
          this.conversations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Conversations {
  int? id;
  int? userId;
  String? userMessage;
  String? aiReply;
  String? createdAt;
  String? updatedAt;

  Conversations(
      {this.id,
      this.userId,
      this.userMessage,
      this.aiReply,
      this.createdAt,
      this.updatedAt});

  Conversations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userMessage = json['user_message'];
    aiReply = json['ai_reply'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['user_message'] = this.userMessage;
    data['ai_reply'] = this.aiReply;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
