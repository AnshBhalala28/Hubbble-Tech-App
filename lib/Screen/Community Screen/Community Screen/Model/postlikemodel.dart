class PostLikeModel {
  int? status;
  String? message;
  int? likesCount;
  int? dislikesCount;

  PostLikeModel(
      {this.status, this.message, this.likesCount, this.dislikesCount});

  PostLikeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    likesCount = json['likes_count'];
    dislikesCount = json['dislikes_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['likes_count'] = this.likesCount;
    data['dislikes_count'] = this.dislikesCount;
    return data;
  }
}
