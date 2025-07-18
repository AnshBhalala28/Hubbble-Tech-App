// ignore_for_file: unnecessary_this, unnecessary_new

class SearchProductModel {
  int? status;
  String? message;
  List<Data>? data;

  SearchProductModel({this.status, this.message, this.data});

  SearchProductModel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  String? name;
  String? price;
  String? offerPrice;
  String? description;
  List<String>? features;
  List<String>? images;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data({
    this.id,
    this.name,
    this.price,
    this.offerPrice,
    this.description,
    this.features,
    this.images,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    description = json['description'];
    features =
        json['features'] is List
            ? List<String>.from(json['features'])
            : (json['features'] != null ? [json['features']] : []);
    images =
        json['images'] is List
            ? List<String>.from(json['images'])
            : (json['images'] != null ? [json['images']] : []);

    image = json['image'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['offer_price'] = this.offerPrice;
    data['description'] = this.description;
    data['features'] = this.features;
    data['images'] = this.images;
    data['image'] = this.image;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
