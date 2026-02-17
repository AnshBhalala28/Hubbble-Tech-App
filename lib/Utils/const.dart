// ignore_for_file: non_constant_identifier_names, constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Ui/CartScreen/model/amendOrderModal.dart'
    show AmendOrderModal;
import 'package:wavee/Ui/CartScreen/model/removeAmendModal.dart';
import 'package:wavee/Utils/storeUserData.dart' show SaveDataLocal;

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
import '../Ui/Booking/modal/statusModal.dart';
import '../Ui/BuyProduct/modal/placeOrderModel.dart';
import '../Ui/CartScreen/model/amendPaymentModal.dart';
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
import '../Ui/NotificationPage/modal/Notification_Model.dart';
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

/// ============================================================
/// HELPER FUNCTIONS
/// ============================================================

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
  /// Dev Url
  static String BASEURL = "https://development.wavee.ai/api/";

  /// Og Url
  // static String BASEURL = "https://portal.wavee.ai/api/";
  static String weatherApi =
      dotenv.env['WEATHER_API'] ?? 'NO WEATHER_API FOUND';
  static const String path = "assets/Svg/";
  static const String manrope1 = "AlbertSans-SemiBold";

  static const String manropeSemiBold = "AlbertSans-Bold";
  static const String manropeBold = "AlbertSans-SemiBold";
  static const String manrope = "AlbertSans";
  static const String AlbertSansLight = "AlbertSans-Light";

  static const String homeScreen = "assets/images/homescreen_map.png";
  static const String home = "${path}home.svg";
  static const String cart = "${path}cart.svg";
  static const String chat1 = "${path}chat1.svg";
  static const String community = "${path}community.svg";
  static const String chat = "${path}chat.svg";
  static const String parcel = "${path}parcels.svg";
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
  static const String visitorScreen = "${path}visitorScreen.svg";

  /// bottombar svgs
  static const String bottomOne = "assets/bottomSvgs/bottom-one.svg";
  static const String bottomTwo = "assets/bottomSvgs/bottom-two.svg";
  static const String bottomThree = "assets/bottomSvgs/bottom-three.svg";
  static const String bottomFour = "assets/bottomSvgs/bottom-four.svg";
  static const String spotlightIcon = "assets/bottomSvgs/spotlight.svg";
  static const String chatHomeIcon = "assets/bottomSvgs/chatHome.svg";
  static const String aprtmentIcon = "assets/bottomSvgs/aprtment.svg";
  static const String visitorHomeIcon = "assets/bottomSvgs/visitorHome.svg";
  static const String maintainIcon = "assets/bottomSvgs/maintain.svg";
  static const String amenityIcon = "assets/bottomSvgs/amentiti.svg";
  static const String calendrIcon = "assets/bottomSvgs/clndr.svg";
  static const String ordrsIcon = "assets/bottomSvgs/ordrs.svg";
  static const String bookinsIcon = "assets/bottomSvgs/bookins.svg";
  static const String eventsIcon = "assets/bottomSvgs/event.svg";
  static const String shoppinsIcon = "assets/bottomSvgs/shoping.svg";
  static const String petsIcon = "assets/bottomSvgs/pets.svg";
  static const String termsIcon = "assets/bottomSvgs/termas.svg";
  static const String securityIcon = "assets/bottomSvgs/securty.svg";
  static const String piracyIcon = "assets/bottomSvgs/priicy.svg";
  static const String personIcon = "assets/bottomSvgs/person.svg";
  static const String dark = "assets/Svg/dark.svg";
  static const String light = "assets/Svg/light.svg";
  static const String emptyCart = "assets/Svg/emptyCart.svg";
  static const String weatherCloudy = "assets/Svg/weather_cloudy.svg";
  static const String weatherRainy = "assets/Svg/weather_rainy.svg";
  static const String weatherThunder = "assets/Svg/weather_thunder.svg";
  static const String weatherSnow = "assets/Svg/weather_snow.svg";
  static const String weatherFog = "assets/Svg/weather_fog.svg";
}

/// ============================================================
/// GLOBAL VARIABLES (STATE)
/// ============================================================

/// --- Authentication & Profile ---
LoginModel? loginModel;
Forgotpasswordmodel? forgotpasswordmodel;
DeleteAccountModel? deleteAccountModel;
ProfileModel? profileModel;
UserPersonalInfoModel? userpersonalInfoModel;
ResidentAppUserprofileModel? residentappuserprofileModel;

/// --- Home & Dashboard ---
ParcelViewModal? parcelViewModal;
ParcelShowCountModel? parcelShowCountModel;
VisitorShowCountModel? visitorShowCountModel;
LatestVisitorModal? latestVisitorModal;
ChatShowCountModal? chatShowCountModal;
NotificationModell? notificationmodel;

/// --- Community & Business ---
BusinessProfileModel? businessprofileModel;
BusnessViewModal? busnessviewmodal;
BussinessLikeModel? bussinesslikemodel;
BusnessSearchModal? busnesssearchModal;
GetLikeModal? getlikeModal;
GetVisitedModal? getvisitedModal;
CategoriesModel? categoriesModel;
ViewCategoriesModel? viewcategoriesmodel;
DwellTimeModel? dwelltimemodel;
PostAsViewedModel? postasviewedmodel;
OfferPromoAsViewedModel? offerpromoAsviewedmodel;
SearchProductModel? searchproductmodel;

/// --- Message Board & Groups ---
MessageBoardModal? messageBoardModal;
PostLikeModel? postlikemodel;
ChatUserListModel? chatuserlistmodel;
GetGroupListModel? getgrouplistmodel;
CreateGroupModel? creategroupmodel;
GroupProfileModel? groupprofileModel;
RemoveGroupMemberModel? removegroupMemberModel;
AddGroupMemberModel? addgroupMemberModel;
DeleteGroupModel? deletegroupModel;
GetPostCommentsModel? getpostCommentsModel;
MessageboardpostLikeModel? messageboardpostlikeModel;
SendPostCommentsModel? sendpostCommentsModel;
Localpost_model? localpost_model;
Localpost_comments_Model? localpostCommentsModel;
Add_Post_Model? add_Post_Model;

/// --- Chat & Messaging ---
ChatModel? chatModel;
MessageModel? messageModel;
SendMessageModel? sendMessageModel;
SendMsgModel? sendmsgModel;
GetMsgModel? getmsgModel;
ChatbotDataModal? chatbotDataModal;
SendChatModal? sendChatModal;
OrdersendMessageModel? ordersendmessagemodel;
ChatStoryModal? chatStories;

/// --- Friends & Requests ---
RequestModal? requestmodal;
RemoveFriendModel? removefriendModel;
CreateFriendModel? createfriendModel;
GetFriendListModel? getfriendListModel;
GetRequestModel? getrequestModel;
MyRequestModel? myRequestModel;
OnGoingFreindRequestModel? onGoingFreindRequestModel;
MyGroupRequestModel? myGroupRequestModel;

/// --- Events ---
EventlistModel? eventlistModel;
EventlistModel? event_list_Model;
SendeventModel? sendeventModel;
EventBookingModal? eventBookingModal;
EventDetailModel? eventDetailModel;
EventDetailModal? eventDetailModal;

/// --- Booking & Amenities ---
AmenitiesModel? amenitiesModel;
AmenitiesModel? aneminitiesDataModel;
AllAmenitiesModel? allAmenitiesModel;
RejectBookingModel? rejectBookingModel;
BookAmenitiesStatusModel? bookAmenitiesStatusModel;
StatusModal? statusModal;

/// --- Maintenance & Services ---
MaintenanceModel? maintenanceModel;
MaintenanceDetailModel? maintenanceDetailModel;
ServiceDetailsModel? servicedetailsmodel;
ServiceOrderDetail? serviceOrderDetail;
ServiceViewModel? serviceViewModel;
ServiceBookingModel? serviceBookingModel;

/// --- E-Commerce & Cart ---
ProductViewModel? productViewModel;
ShowAllReviewModel? showAllReviewModel;
CartDetailsModel? cartDetailsModel;
CartDetailsModel? checkoutTotal;
MyOrderModel? myOrderModel;
OrderDetailModel? orderDetailModel;
PlaceOrderModel? placeOrderModel;
CategoryModal? categoryModal;
CategoryDetailModal? categoryDetailModal;
AmendOrderModal? amendOrderModal;
AmendPaymentModal? amendPaymentModal;
RemoveAmendModal? removeAmend;

/// --- Stories ---
StroyModel? stroymodel;

/// ============================================================
/// DATA CLEANUP (LOGOUT)
/// ============================================================
handleDataClear(BuildContext context) async {
  print("🧹 GlobalStore: Wiping all sensitive user data...");

  /// --- Authentication & Profile ---
  loginModel = null;
  forgotpasswordmodel = null;
  deleteAccountModel = null;
  profileModel = null;
  userpersonalInfoModel = null;
  residentappuserprofileModel = null;

  /// --- Home & Dashboard ---
  parcelViewModal = null;
  parcelShowCountModel = null;
  visitorShowCountModel = null;
  latestVisitorModal = null;
  chatShowCountModal = null;
  notificationmodel = null;

  /// --- Community & Business ---
  businessprofileModel = null;
  busnessviewmodal = null;
  bussinesslikemodel = null;
  busnesssearchModal = null;
  getlikeModal = null;
  getvisitedModal = null;
  categoriesModel = null;
  viewcategoriesmodel = null;
  dwelltimemodel = null;
  postasviewedmodel = null;
  offerpromoAsviewedmodel = null;
  searchproductmodel = null;

  /// --- Message Board & Groups ---
  messageBoardModal = null;
  postlikemodel = null;
  chatuserlistmodel = null;
  getgrouplistmodel = null;
  creategroupmodel = null;
  groupprofileModel = null;
  removegroupMemberModel = null;
  addgroupMemberModel = null;
  deletegroupModel = null;
  getpostCommentsModel = null;
  messageboardpostlikeModel = null;
  sendpostCommentsModel = null;
  localpost_model = null;
  localpostCommentsModel = null;
  add_Post_Model = null;

  /// --- Chat & Messaging ---
  chatModel = null;
  messageModel = null;
  sendMessageModel = null;
  sendmsgModel = null;
  getmsgModel = null;
  chatbotDataModal = null;
  sendChatModal = null;
  ordersendmessagemodel = null;
  chatStories = null;

  /// --- Friends & Requests ---
  requestmodal = null;
  removefriendModel = null;
  createfriendModel = null;
  getfriendListModel = null;
  getrequestModel = null;
  myRequestModel = null;
  onGoingFreindRequestModel = null;
  myGroupRequestModel = null;

  /// --- Events ---
  eventlistModel = null;
  event_list_Model = null;
  sendeventModel = null;
  eventBookingModal = null;
  eventDetailModel = null;
  eventDetailModal = null;

  /// --- Booking & Amenities ---
  amenitiesModel = null;
  aneminitiesDataModel = null;
  allAmenitiesModel = null;
  rejectBookingModel = null;
  bookAmenitiesStatusModel = null;
  statusModal = null;

  /// --- Maintenance & Services ---
  maintenanceModel = null;
  maintenanceDetailModel = null;
  servicedetailsmodel = null;
  serviceOrderDetail = null;
  serviceViewModel = null;
  serviceBookingModel = null;

  /// --- E-Commerce & Cart ---
  productViewModel = null;
  showAllReviewModel = null;
  cartDetailsModel = null;
  checkoutTotal = null;
  myOrderModel = null;
  orderDetailModel = null;
  placeOrderModel = null;
  categoryModal = null;
  categoryDetailModal = null;
  amendOrderModal = null;
  amendPaymentModal = null;
  removeAmend = null;

  /// --- Stories ---
  stroymodel = null;

  // Clear Local Storage
  await SaveDataLocal.clearUserData();

  // Reset Theme (Wait for this to finish!)
  if (context.mounted) {
    final themeController = Provider.of<ThemeController>(
      context,
      listen: false,
    );
    await themeController.resetTheme();
  }
  print("✅ All global data wiped successfully.");
}
