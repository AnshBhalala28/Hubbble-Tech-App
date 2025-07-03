class BusnessViewModal {
  int? status;
  String? message;
  Data? data;

  BusnessViewModal({this.status, this.message, this.data});

  BusnessViewModal.fromJson(Map<String, dynamic> json) {
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
  Business? business;
  bool? isLiked;
  bool? isVisited;
  var distanceToBusiness;
  List<NearbyBusinesses>? nearbyBusinesses;
  List<Posts>? posts;
  List<OfferPromotions>? offerPromotions;
  List<Events>? events;
  List<Services>? services;
  List<Products>? products;

  Data(
      {this.business,
      this.isLiked,
      this.isVisited,
      this.distanceToBusiness,
      this.nearbyBusinesses,
      this.posts,
      this.offerPromotions,
      this.events,
      this.services,
      this.products});

  Data.fromJson(Map<String, dynamic> json) {
    business = json['business'] != null
        ? new Business.fromJson(json['business'])
        : null;
    isLiked = json['is_liked'];
    isVisited = json['is_visited'];
    distanceToBusiness = json['distance_to_business'];
    if (json['nearby_businesses'] != null) {
      nearbyBusinesses = <NearbyBusinesses>[];
      json['nearby_businesses'].forEach((v) {
        nearbyBusinesses!.add(new NearbyBusinesses.fromJson(v));
      });
    }
    if (json['posts'] != null) {
      posts = <Posts>[];
      json['posts'].forEach((v) {
        posts!.add(new Posts.fromJson(v));
      });
    }
    if (json['offerPromotions'] != null) {
      offerPromotions = <OfferPromotions>[];
      json['offerPromotions'].forEach((v) {
        offerPromotions!.add(new OfferPromotions.fromJson(v));
      });
    }
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        events!.add(new Events.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(new Services.fromJson(v));
      });
    }
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(new Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.business != null) {
      data['business'] = this.business!.toJson();
    }
    data['is_liked'] = this.isLiked;
    data['is_visited'] = this.isVisited;
    data['distance_to_business'] = this.distanceToBusiness;
    if (this.nearbyBusinesses != null) {
      data['nearby_businesses'] =
          this.nearbyBusinesses!.map((v) => v.toJson()).toList();
    }
    if (this.posts != null) {
      data['posts'] = this.posts!.map((v) => v.toJson()).toList();
    }
    if (this.offerPromotions != null) {
      data['offerPromotions'] =
          this.offerPromotions!.map((v) => v.toJson()).toList();
    }
    if (this.events != null) {
      data['events'] = this.events!.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Business {
  int? id;
  int? userId;
  int? subId;
  var stripeSubscriptionId;
  String? logo;
  String? businessName;
  String? about;
  String? description;
  String? industry;
  OpeningHours? openingHours;
  String? website;
  int? categoryId;
  int? subCategoryId;
  List<Tags>? tags;
  String? businessServices;
  String? experience;
  String? businessAddress;
  String? subStartDate;
  String? subEndDate;
  String? subStatus;
  String? latitude;
  String? longitude;
  var media;
  String? creditBalance;
  var stripeAccountId;
  var isStripeConnected;
  var stripeAccessToken;
  String? onboardedAt;
  int? loyaltyOrderThreshold;
  String? loyaltyDiscountPercentage;
  int? serviceStatus;
  int? productStatus;
  int? chatStatus;
  String? createdAt;
  String? updatedAt;
  LoyaltyInfo? loyaltyInfo;
  User? user;

  Business(
      {this.id,
      this.userId,
      this.subId,
      this.stripeSubscriptionId,
      this.logo,
      this.businessName,
      this.about,
      this.description,
      this.industry,
      this.openingHours,
      this.website,
      this.categoryId,
      this.subCategoryId,
      this.tags,
      this.businessServices,
      this.experience,
      this.businessAddress,
      this.subStartDate,
      this.subEndDate,
      this.subStatus,
      this.latitude,
      this.longitude,
      this.media,
      this.creditBalance,
      this.stripeAccountId,
      this.isStripeConnected,
      this.stripeAccessToken,
      this.onboardedAt,
      this.loyaltyOrderThreshold,
      this.loyaltyDiscountPercentage,
      this.serviceStatus,
      this.productStatus,
      this.chatStatus,
      this.createdAt,
      this.updatedAt,
      this.loyaltyInfo,
      this.user});

  Business.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    subId = json['sub_id'];
    stripeSubscriptionId = json['stripe_subscription_id'];
    logo = json['logo'];
    businessName = json['business_name'];
    about = json['about'];
    description = json['description'];
    industry = json['industry'];
    openingHours = json['opening_hours'] != null
        ? new OpeningHours.fromJson(json['opening_hours'])
        : null;
    website = json['website'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(new Tags.fromJson(v));
      });
    }
    businessServices = json['business_services'];
    experience = json['experience'];
    businessAddress = json['business_address'];
    subStartDate = json['sub_start_date'];
    subEndDate = json['sub_end_date'];
    subStatus = json['sub_status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    media = json['media'];
    creditBalance = json['credit_balance'];
    stripeAccountId = json['stripe_account_id'];
    isStripeConnected = json['is_stripe_connected'];
    stripeAccessToken = json['stripe_access_token'];
    onboardedAt = json['onboarded_at'];
    loyaltyOrderThreshold = json['loyalty_order_threshold'];
    loyaltyDiscountPercentage = json['loyalty_discount_percentage'];
    serviceStatus = json['service_status'];
    productStatus = json['product_status'];
    chatStatus = json['chat_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    loyaltyInfo = json['loyalty_info'] != null
        ? new LoyaltyInfo.fromJson(json['loyalty_info'])
        : null;
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['sub_id'] = this.subId;
    data['stripe_subscription_id'] = this.stripeSubscriptionId;
    data['logo'] = this.logo;
    data['business_name'] = this.businessName;
    data['about'] = this.about;
    data['description'] = this.description;
    data['industry'] = this.industry;
    if (this.openingHours != null) {
      data['opening_hours'] = this.openingHours!.toJson();
    }
    data['website'] = this.website;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    data['business_services'] = this.businessServices;
    data['experience'] = this.experience;
    data['business_address'] = this.businessAddress;
    data['sub_start_date'] = this.subStartDate;
    data['sub_end_date'] = this.subEndDate;
    data['sub_status'] = this.subStatus;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['media'] = this.media;
    data['credit_balance'] = this.creditBalance;
    data['stripe_account_id'] = this.stripeAccountId;
    data['is_stripe_connected'] = this.isStripeConnected;
    data['stripe_access_token'] = this.stripeAccessToken;
    data['onboarded_at'] = this.onboardedAt;
    data['loyalty_order_threshold'] = this.loyaltyOrderThreshold;
    data['loyalty_discount_percentage'] = this.loyaltyDiscountPercentage;
    data['service_status'] = this.serviceStatus;
    data['product_status'] = this.productStatus;
    data['chat_status'] = this.chatStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.loyaltyInfo != null) {
      data['loyalty_info'] = this.loyaltyInfo!.toJson();
    }
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class OpeningHours {
  Monday? monday;
  Tuesday? tuesday;
  Monday? wednesday;
  Monday? thursday;
  Tuesday? friday;
  Tuesday? saturday;
  Tuesday? sunday;

  OpeningHours(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday});

  OpeningHours.fromJson(Map<String, dynamic> json) {
    monday =
        json['Monday'] != null ? new Monday.fromJson(json['Monday']) : null;
    tuesday =
        json['Tuesday'] != null ? new Tuesday.fromJson(json['Tuesday']) : null;
    wednesday = json['Wednesday'] != null
        ? new Monday.fromJson(json['Wednesday'])
        : null;
    thursday =
        json['Thursday'] != null ? new Monday.fromJson(json['Thursday']) : null;
    friday =
        json['Friday'] != null ? new Tuesday.fromJson(json['Friday']) : null;
    saturday = json['Saturday'] != null
        ? new Tuesday.fromJson(json['Saturday'])
        : null;
    sunday =
        json['Sunday'] != null ? new Tuesday.fromJson(json['Sunday']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.monday != null) {
      data['Monday'] = this.monday!.toJson();
    }
    if (this.tuesday != null) {
      data['Tuesday'] = this.tuesday!.toJson();
    }
    if (this.wednesday != null) {
      data['Wednesday'] = this.wednesday!.toJson();
    }
    if (this.thursday != null) {
      data['Thursday'] = this.thursday!.toJson();
    }
    if (this.friday != null) {
      data['Friday'] = this.friday!.toJson();
    }
    if (this.saturday != null) {
      data['Saturday'] = this.saturday!.toJson();
    }
    if (this.sunday != null) {
      data['Sunday'] = this.sunday!.toJson();
    }
    return data;
  }
}

class Monday {
  String? open;
  String? close;
  bool? closed;

  Monday({this.open, this.close, this.closed});

  Monday.fromJson(Map<String, dynamic> json) {
    open = json['open'];
    close = json['close'];
    closed = json['closed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['open'] = this.open;
    data['close'] = this.close;
    data['closed'] = this.closed;
    return data;
  }
}

class Tuesday {
  String? open;
  String? close;
  bool? closed;

  Tuesday({this.open, this.close, this.closed});

  Tuesday.fromJson(Map<String, dynamic> json) {
    open = json['open'];
    close = json['close'];
    closed = json['closed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['open'] = this.open;
    data['close'] = this.close;
    data['closed'] = this.closed;
    return data;
  }
}

class Tags {
  String? name;
  String? img;

  Tags({this.name, this.img});

  Tags.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['img'] = this.img;
    return data;
  }
}

class LoyaltyInfo {
  int? loyaltyOrderThreshold;
  String? loyaltyDiscountPercentage;
  int? ordersCompletedWithBusiness;
  int? ordersLeftForNextDiscount;

  LoyaltyInfo(
      {this.loyaltyOrderThreshold,
      this.loyaltyDiscountPercentage,
      this.ordersCompletedWithBusiness,
      this.ordersLeftForNextDiscount});

  LoyaltyInfo.fromJson(Map<String, dynamic> json) {
    loyaltyOrderThreshold = json['loyalty_order_threshold'];
    loyaltyDiscountPercentage = json['loyalty_discount_percentage'];
    ordersCompletedWithBusiness = json['orders_completed_with_business'];
    ordersLeftForNextDiscount = json['orders_left_for_next_discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loyalty_order_threshold'] = this.loyaltyOrderThreshold;
    data['loyalty_discount_percentage'] = this.loyaltyDiscountPercentage;
    data['orders_completed_with_business'] = this.ordersCompletedWithBusiness;
    data['orders_left_for_next_discount'] = this.ordersLeftForNextDiscount;
    return data;
  }
}

class User {
  int? id;
  int? role;
  String? name;
  String? email;
  var emailVerifiedAt;
  var dPassword;
  int? mobileNo;
  String? gender;
  var dateOfBirth;
  Address? address;

  String? psLatitude;
  String? psLongitude;
  var fcmToken;
  String? forgetPassKey;
  var moduleLock;
  String? status;
  String? profile;
  String? createdAt;
  String? updatedAt;

  User(
      {this.id,
      this.role,
      this.name,
      this.email,
      this.emailVerifiedAt,
      this.dPassword,
      this.mobileNo,
      this.gender,
      this.dateOfBirth,
      this.address,
      this.psLatitude,
      this.psLongitude,
      this.fcmToken,
      this.forgetPassKey,
      this.moduleLock,
      this.status,
      this.profile,
      this.createdAt,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    dPassword = json['d_password'];
    mobileNo = json['mobile_no'];
    gender = json['gender'];
    dateOfBirth = json['date_of_birth'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;

    psLatitude = json['ps_latitude'];
    psLongitude = json['ps_longitude'];
    fcmToken = json['fcm_token'];
    forgetPassKey = json['forget_pass_key'];
    moduleLock = json['module_lock'];
    status = json['status'];
    profile = json['profile'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['d_password'] = this.dPassword;
    data['mobile_no'] = this.mobileNo;
    data['gender'] = this.gender;
    data['date_of_birth'] = this.dateOfBirth;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }

    data['ps_latitude'] = this.psLatitude;
    data['ps_longitude'] = this.psLongitude;
    data['fcm_token'] = this.fcmToken;
    data['forget_pass_key'] = this.forgetPassKey;
    data['module_lock'] = this.moduleLock;
    data['status'] = this.status;
    data['profile'] = this.profile;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Address {
  String? address;
  String? city;
  String? country;
  String? zipCode;

  Address({this.address, this.city, this.country, this.zipCode});

  Address.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    city = json['city'];
    country = json['country'];
    zipCode = json['zip_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['city'] = this.city;
    data['country'] = this.country;
    data['zip_code'] = this.zipCode;
    return data;
  }
}

class NearbyBusinesses {
  int? id;
  int? userId;
  int? subId;
  var stripeSubscriptionId;
  String? logo;
  String? businessName;
  String? about;
  String? description;
  String? industry;
  int? categoryId;
  int? subCategoryId;
  List<Tags>? tags;
  String? businessServices;
  String? experience;
  String? businessAddress;
  String? subStartDate;
  String? subEndDate;
  String? subStatus;
  String? latitude;
  String? longitude;
  var media;
  String? creditBalance;
  var stripeAccountId;
  var isStripeConnected;
  var stripeAccessToken;
  String? onboardedAt;
  String? createdAt;
  String? updatedAt;
  var distance;

  NearbyBusinesses(
      {this.id,
      this.userId,
      this.subId,
      this.stripeSubscriptionId,
      this.logo,
      this.businessName,
      this.about,
      this.description,
      this.industry,
      this.categoryId,
      this.subCategoryId,
      this.tags,
      this.businessServices,
      this.experience,
      this.businessAddress,
      this.subStartDate,
      this.subEndDate,
      this.subStatus,
      this.latitude,
      this.longitude,
      this.media,
      this.creditBalance,
      this.stripeAccountId,
      this.isStripeConnected,
      this.stripeAccessToken,
      this.onboardedAt,
      this.createdAt,
      this.updatedAt,
      this.distance});

  NearbyBusinesses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    subId = json['sub_id'];
    stripeSubscriptionId = json['stripe_subscription_id'];
    logo = json['logo'];
    businessName = json['business_name'];
    about = json['about'];
    description = json['description'];
    industry = json['industry'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(new Tags.fromJson(v));
      });
    }
    businessServices = json['business_services'];
    experience = json['experience'];
    businessAddress = json['business_address'];
    subStartDate = json['sub_start_date'];
    subEndDate = json['sub_end_date'];
    subStatus = json['sub_status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    media = json['media'];
    creditBalance = json['credit_balance'];
    stripeAccountId = json['stripe_account_id'];
    isStripeConnected = json['is_stripe_connected'];
    stripeAccessToken = json['stripe_access_token'];
    onboardedAt = json['onboarded_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['sub_id'] = this.subId;
    data['stripe_subscription_id'] = this.stripeSubscriptionId;
    data['logo'] = this.logo;
    data['business_name'] = this.businessName;
    data['about'] = this.about;
    data['description'] = this.description;
    data['industry'] = this.industry;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    data['business_services'] = this.businessServices;
    data['experience'] = this.experience;
    data['business_address'] = this.businessAddress;
    data['sub_start_date'] = this.subStartDate;
    data['sub_end_date'] = this.subEndDate;
    data['sub_status'] = this.subStatus;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['media'] = this.media;
    data['credit_balance'] = this.creditBalance;
    data['stripe_account_id'] = this.stripeAccountId;
    data['is_stripe_connected'] = this.isStripeConnected;
    data['stripe_access_token'] = this.stripeAccessToken;
    data['onboarded_at'] = this.onboardedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['distance'] = this.distance;
    return data;
  }
}

class Posts {
  int? id;
  String? type;
  String? file;
  String? status;

  Posts({this.id, this.type, this.file, this.status});

  Posts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    file = json['file'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['file'] = this.file;
    data['status'] = this.status;
    return data;
  }
}

class OfferPromotions {
  int? id;
  String? title;
  String? url;
  String? files;

  OfferPromotions({this.id, this.title, this.url, this.files});

  OfferPromotions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    url = json['url'];
    files = json['files'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['url'] = this.url;
    data['files'] = this.files;
    return data;
  }
}

class Events {
  int? id;
  String? title;
  String? eventDate;
  String? location;
  String? status;
  String? attachment;
  String? requestEvent;

  Events(
      {this.id,
      this.title,
      this.eventDate,
      this.location,
      this.status,
      this.attachment,
      this.requestEvent});

  Events.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    eventDate = json['event_date'];
    location = json['location'];
    status = json['status'];
    attachment = json['attachment'];
    requestEvent = json['request_event'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['event_date'] = this.eventDate;
    data['location'] = this.location;
    data['status'] = this.status;
    data['attachment'] = this.attachment;
    data['request_event'] = this.requestEvent;
    return data;
  }
}

class Services {
  int? id;
  String? title;
  String? price;
  String? images;
  String? availability;

  Services({this.id, this.title, this.price, this.images, this.availability});

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    images = json['images'];
    availability = json['availability'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['images'] = this.images;
    data['availability'] = this.availability;
    return data;
  }
}

class Products {
  int? id;
  int? userId;
  String? name;
  String? price;
  String? offerPrice;
  var quantity;
  String? description;
  String? features;
  String? status;
  bool? isFeatured;
  String? image;
  List<String>? images;
  String? createdAt;
  String? updatedAt;
  String? productCategoryName;

  Products(
      {this.id,
      this.userId,
      this.name,
      this.price,
      this.offerPrice,
      this.quantity,
      this.description,
      this.features,
      this.status,
      this.isFeatured,
      this.image,
      this.images,
      this.createdAt,
      this.productCategoryName,
      this.updatedAt});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    price = json['price'];
    offerPrice = json['offer_price'];
    quantity = json['quantity'];
    description = json['description'];
    features = json['features'];
    status = json['status'];
    isFeatured = json['is_featured'];
    image = json['image'];

    if (json['images'] != null && json['images'] is List) {
      images = List<String>.from(json['images']);
    } else {
      images = [];
    }

    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    productCategoryName = json['product_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['price'] = this.price;
    data['offer_price'] = this.offerPrice;
    data['quantity'] = this.quantity;
    data['description'] = this.description;
    data['features'] = this.features;
    data['status'] = this.status;
    data['is_featured'] = this.isFeatured;
    data['image'] = this.image;
    data['images'] = this.images;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['product_category_name'] = this.productCategoryName;
    return data;
  }
}
