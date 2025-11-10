// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:intl/intl.dart';

import '../Ui/Authentication/modal/DeleteAccountModel.dart';
import '../Ui/Authentication/modal/forgotPasswordModel.dart';
import '../Ui/Authentication/modal/login_model.dart';
import '../Ui/Booking/modal/AllAmenitiesModel.dart';
import '../Ui/Booking/modal/amenitiesBookStatusModel.dart';
import '../Ui/Booking/modal/bookingModel.dart';
import '../Ui/Booking/modal/eventBookingModal.dart';
import '../Ui/Booking/modal/eventDetailModel.dart';
import '../Ui/Booking/modal/rejectBookingModal.dart';
import '../Ui/Booking/modal/serviceBookingModel.dart';
import '../Ui/BuyProduct/modal/placeOrderModel.dart';
import '../Ui/CartScreen/model/cartDetailsModal.dart';
import '../Ui/Category/Modal/categoryDetailModal.dart';
import '../Ui/ChatScreen/modal/ChatStoryModal.dart';
import '../Ui/ChatScreen/modal/chatScreenModel.dart';
import '../Ui/CommunityDetailsPage/modal/SearchProductModel.dart';
import '../Ui/CommunityDetailsPage/modal/category_modal.dart';
import '../Ui/CommunityScreen/modal/BusinessSearchModal.dart';
import '../Ui/CommunityScreen/modal/BusnessViewModal.dart';
import '../Ui/CommunityScreen/modal/CategoriesModel.dart';
import '../Ui/CommunityScreen/modal/DwellTimeModel.dart';
import '../Ui/CommunityScreen/modal/GetLikeModal.dart';
import '../Ui/CommunityScreen/modal/GetVisitedModal.dart';
import '../Ui/CommunityScreen/modal/OfferPromoAsViewedModel.dart';
import '../Ui/CommunityScreen/modal/PostAsViewedModel.dart';
import '../Ui/CommunityScreen/modal/RequestModal.dart';
import '../Ui/CommunityScreen/modal/StroyModel.dart';
import '../Ui/CommunityScreen/modal/ViewCategoriesModel.dart';
import '../Ui/CommunityScreen/modal/businesslikemodel.dart';
import '../Ui/CommunityScreen/modal/businessprofilemodel.dart';
import '../Ui/CommunityScreen/modal/postlikemodel.dart';
import '../Ui/Event/modal/eventDetailModal.dart';
import '../Ui/Event/modal/eventModel.dart';
import '../Ui/Event/modal/sendEventModel.dart';
import '../Ui/HomeScreen/modal/chatShowCountModal.dart';
import '../Ui/HomeScreen/modal/messageBoardModal.dart';
import '../Ui/HomeScreen/modal/parcelShowCount.dart';
import '../Ui/HomeScreen/modal/visitorShowCountModel.dart';
import '../Ui/Manintenance/modal/maintenanceDetailsModel.dart';
import '../Ui/Manintenance/modal/maintenance_modal.dart';
import '../Ui/MessageBoard/modal/AddGroupMemberModel.dart';
import '../Ui/MessageBoard/modal/Add_Post_Model.dart';
import '../Ui/MessageBoard/modal/ChatUserListModel.dart';
import '../Ui/MessageBoard/modal/CreateFriendModel.dart';
import '../Ui/MessageBoard/modal/CreateGroupModel.dart';
import '../Ui/MessageBoard/modal/DeleteGroupModel.dart';
import '../Ui/MessageBoard/modal/GetFriendListModel.dart';
import '../Ui/MessageBoard/modal/GetGroupListModel.dart';
import '../Ui/MessageBoard/modal/GetMsgModel.dart';
import '../Ui/MessageBoard/modal/GetPostCommentsModel.dart';
import '../Ui/MessageBoard/modal/GetRequestModel.dart';
import '../Ui/MessageBoard/modal/GroupProfileModel.dart';
import '../Ui/MessageBoard/modal/Localpost_comments_Model.dart';
import '../Ui/MessageBoard/modal/Localpost_model.dart';
import '../Ui/MessageBoard/modal/PostLikeModel.dart';
import '../Ui/MessageBoard/modal/RemoveGroupMemberModel.dart';
import '../Ui/MessageBoard/modal/ResidentAppUserprofileModel.dart';
import '../Ui/MessageBoard/modal/SendMsgModel.dart';
import '../Ui/MessageBoard/modal/SendPostCommentsModel.dart';
import '../Ui/MessageScreen/modal/OrderSendMessageModel.dart';
import '../Ui/MessageScreen/modal/RemoveFriendModel.dart';
import '../Ui/MessageScreen/modal/SendMessageModel.dart';
import '../Ui/MessageScreen/modal/UserPersonalInfoModel.dart';
import '../Ui/MessageScreen/modal/messagescreen_model.dart';
import '../Ui/OpenAiChatbot/modal/chat_bot_data_modal.dart';
import '../Ui/OpenAiChatbot/modal/send_data_model.dart';
import '../Ui/OrderScreen/modal/order_detail_model.dart';
import '../Ui/OrderScreen/modal/order_screen_model.dart';
import '../Ui/OrderScreen/modal/service_order_model.dart';
import '../Ui/OrderScreen/modal/service_view_model.dart';
import '../Ui/Parcel/modal/parcel_model.dart';
import '../Ui/ProductDetailPage/model/all_review_model.dart';
import '../Ui/ServiceDetailPage/modal/ServiceDetailsModel.dart';
import '../Ui/UpcomingRequest/modal/OnGoing_Freind_Request_Model.dart';
import '../Ui/UpcomingRequest/modal/get_my_new_request.dart';
import '../Ui/UpcomingRequest/modal/my_request_model.dart';
import '../Ui/ViewProfile/modal/profile_model.dart';
import '../Ui/Visitor/modal/latest_visitor_modal/latest_visitor_modal.dart';
import '../Ui/productDetailPage/model/product_model.dart';

const String baseUrl = "https://portal.wavee.ai/api";
// const String baseUrl = "https://staging-portal.wavee.ai/api";
const String jsonString = "assets/google_pay.json";

String formatDateTime(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) return "N/A";
  DateTime parsedDate = DateTime.parse(createdAt);
  return "${DateFormat('dd MMM yyyy').format(parsedDate)}, ${DateFormat('hh:mm a').format(parsedDate)}";
}
String formatTime(String time) {
  final parsed = DateFormat("HH:mm:ss").parse(time);
  return DateFormat("hh:mm a").format(parsed);
}
String formatTime12(String? time) {
  if (time == null || time == "N/A" || time.isEmpty) {
    return "N/A";
  }

  try {
    final parsed = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("hh:mm a").format(parsed);
  } catch (e) {
    return "N/A";
  }
}

class AppConstants {
  static String BASEURL = "https://development.wavee.ai/api/";

  /// Og Url
  // static String BASEURL = "https://portal.wavee.ai/api/";

  // static String BASEURL = "https://staging-portal.wavee.ai/api/";

  static const String path = "assets/Svg/";
  static const String manrope1 = "AlbertSans-SemiBold";

  // static const String manropeBold = "AlbertSans-Bold";
  static const String manropeBold = "AlbertSans-SemiBold";
  static const String manrope = "AlbertSans";
  static const String AlbertSansLight = "AlbertSans-Light";

  static const String homeScreen = "assets/images/homescreen_map.png";
  static const String home = "${path}home.svg";
  static const String cart = "${path}cart.svg";
  static const String chat1 = "${path}chat1.svg";
  static const String community = "${path}community.svg";
  static const String chat = "${path}chat.svg";
  static const String parcel = "${path}parcel.svg";
  static const String visitor = "${path}visitor.svg";
  static const String amenities = "${path}amenities.svg";
  static const String building = "${path}building.svg";
  static const String booking = "${path}booking.svg";
  static const String maintance = "${path}maintance.svg";
  static const String events = "${path}events.svg";
  static const String myOrder = "${path}myorder.svg";
  static const String serviceBooking = "${path}servicebooking.svg";
  static const String shopping = "${path}shopping.svg";
  static const String profile = "${path}profile.svg";
  static const String settings = "${path}settings.svg";
  static const String Privacy = "${path}Privacy1.svg";
  static const String terms = "${path}terms.svg";
  static const String messageBoard = "${path}messageboard.svg";
  static const String eventBooking = "${path}eventbookin.svg";
  static const String waveePet = "${path}waveePet.svg";
}

LoginModel? loginModel;
Forgotpasswordmodel? forgotpasswordmodel;
DeleteAccountModel? deleteAccountModel;
ParcelViewModal? parcelViewModal;
BusinessProfileModel? businessprofileModel;
BusnessViewModal? busnessviewmodal;
ProfileModel? profileModel;
ParcelShowCountModel? parcelShowCountModel;
VisitorShowCountModel? visitorShowCountModel;
BussinessLikeModel? bussinesslikemodel;
LatestVisitorModal? latestVisitorModal;
ChatShowCountModal? chatShowCountModal;
MessageBoardModal? messageBoardModal;
ChatModel? chatModel;
MessageModel? messageModel;
BusnessSearchModal? busnesssearchModal;
GetLikeModal? getlikeModal;
GetVisitedModal? getvisitedModal;
SendMessageModel? sendMessageModel;
RequestModal? requestmodal;
EventlistModel? eventlistModel;
NotificationModel? notificationmodel;
EventlistModel? event_list_Model;
SendeventModel? sendeventModel;
CategoriesModel? categoriesModel;
ViewCategoriesModel? viewcategoriesmodel;
PostLikeModel? postlikemodel;
DwellTimeModel? dwelltimemodel;
PostAsViewedModel? postasviewedmodel;
OfferPromoAsViewedModel? offerpromoAsviewedmodel;
ChatUserListModel? chatuserlistmodel;
GetGroupListModel? getgrouplistmodel;
CreateGroupModel? creategroupmodel;
GroupProfileModel? groupprofileModel;
RemoveGroupMemberModel? removegroupMemberModel;
AddGroupMemberModel? addgroupMemberModel;
DeleteGroupModel? deletegroupModel;
RemoveFriendModel? removefriendModel;
UserPersonalInfoModel? userpersonalInfoModel;
SendMsgModel? sendmsgModel;
GetMsgModel? getmsgModel;
CreateFriendModel? createfriendModel;
GetFriendListModel? getfriendListModel;
ChatbotDataModal? chatbotDataModal;
SendChatModal? sendChatModal;
AmenitiesModel? amenitiesModel;
AmenitiesModel? aneminitiesDataModel;
AllAmenitiesModel? allAmenitiesModel;
RejectBookingModel? rejectBookingModel;
BookAmenitiesStatusModel? bookAmenitiesStatusModel;
MaintenanceModel? maintenanceModel;
EventBookingModal? eventBookingModal;
GetPostCommentsModel? getpostCommentsModel;
MessageboardpostLikeModel? messageboardpostlikeModel;
SendPostCommentsModel? sendpostCommentsModel;
MaintenanceDetailModel? maintenanceDetailModel;
EventDetailModel? eventDetailModel;
ProductViewModel? productViewModel;
ShowAllReviewModel? showAllReviewModel;
CartDetailsModel? cartDetailsModel;
CartDetailsModel? checkoutTotal;
MyOrderModel? myOrderModel;
OrderDetailModel? orderDetailModel;
PlaceOrderModel? placeOrderModel;
StroyModel? stroymodel;
GetRequestModel? getrequestModel;
MyRequestModel? myRequestModel;
OnGoingFreindRequestModel? onGoingFreindRequestModel;
MyGroupRequestModel? myGroupRequestModel;
ResidentAppUserprofileModel? residentappuserprofileModel;
ServiceDetailsModel? servicedetailsmodel;
ServiceOrderDetail? serviceOrderDetail;
ServiceViewModel? serviceViewModel;
ServiceBookingModel? serviceBookingModel;
Localpost_model? localpost_model;
Localpost_comments_Model? localpostCommentsModel;
Add_Post_Model? add_Post_Model;
CategoryModal? categoryModal;
CategoryDetailModal? categoryDetailModal;
OrdersendMessageModel? ordersendmessagemodel;
SearchProductModel? searchproductmodel;
ChatStoryModal? chatStories;
EventDetailModal? eventDetailModal;
