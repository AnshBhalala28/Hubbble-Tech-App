class AmendPaymentModal {
  int? status;
  String? message;
  Data? data;

  AmendPaymentModal({this.status, this.message, this.data});

  AmendPaymentModal.fromJson(Map<String, dynamic> json) {
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
  String? paymentUrl;
  String? sessionId;
  int? extraAmount;

  Data({this.paymentUrl, this.sessionId, this.extraAmount});

  Data.fromJson(Map<String, dynamic> json) {
    paymentUrl = json['payment_url'];
    sessionId = json['session_id'];
    extraAmount = json['extra_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payment_url'] = this.paymentUrl;
    data['session_id'] = this.sessionId;
    data['extra_amount'] = this.extraAmount;
    return data;
  }
}
