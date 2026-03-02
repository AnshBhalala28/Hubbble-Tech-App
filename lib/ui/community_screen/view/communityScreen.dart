import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/themeButton.dart';
import 'package:wavee/ui/community_screen/modal/BusinessSearchModal.dart';
import 'package:wavee/ui/community_screen/modal/BusnessViewModal.dart';
import 'package:wavee/ui/community_screen/modal/CategoriesModel.dart';
import 'package:wavee/ui/community_screen/modal/GetLikeModal.dart';
import 'package:wavee/ui/community_screen/modal/GetVisitedModal.dart';
import 'package:wavee/ui/community_screen/modal/OfferPromoAsViewedModel.dart';
import 'package:wavee/ui/community_screen/modal/ViewCategoriesModel.dart';
import 'package:wavee/ui/community_screen/modal/businesslikemodel.dart';
import 'package:wavee/ui/community_screen/modal/businessprofilemodel.dart';
import 'package:wavee/ui/event/modal/sendEventModel.dart';
import 'package:wavee/ui/view_profile/modal/profile_model.dart';

import '../../../../utils/const.dart';
import '../../../../utils/loader.dart';
import '../../../utils/bottomBar.dart';
import '../../../utils/chatCounter.dart';
import '../../../utils/checkInternetConnection.dart';
import '../../../utils/customBatan.dart';
import '../../../utils/errorDialog.dart';
import '../../community_details_page/view/communityDetailPage.dart';
import '../../event/provider/eventProvider.dart';
import '../../event/view/eventDetails.dart';
import '../../home_screen/view/homePage.dart';
import '../../message_screen/view/messageScreen.dart';
import '../../product_detail_page/view/productDetailPage.dart';
import '../../service_detail_page/view/serviceDetailsPage.dart';
import '../../view_profile/provider/profileProvider.dart';
import '../../view_profile/view/viewProfile.dart';
import '../provider/communityProvider.dart';
import 'fullScreenImageView.dart';
import 'storyView.dart';

class CommunityScreen extends StatefulWidget {
  int? selected;

  CommunityScreen({super.key, this.selected});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with WidgetsBindingObserver {
  final GlobalCountsController countsController = Get.find();

  final TextEditingController search = TextEditingController();
  final TextEditingController request = TextEditingController();
  late GoogleMapController mapController;
  Map<int, bool> isSelected = {};
  Set<Marker> _markers = {};
  String AppLat = '';
  String AppLon = '';
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  int sel = 0;
  bool isLoading = true;
  bool isProfileLoaded = false;
  List<String> categories = [
    'Posts',
    'Events',
    'Offers/Promotions',
    'Services',
  ];
  int selectedCategory = 0;
  bool showSearchList = false;
  String selectedUserId = '';
  bool markload = true;
  bool isMapLoading = true;
  List<Color> categoryColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.blueAccent,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  Color getCategoryColor(String categoryName) {
    int hash = categoryName.hashCode;
    int index = hash % categoryColors.length;
    return categoryColors[index];
  }

  bool _isBottomSheetOpen = false;
  Map<String, List<Data1>> locationGroups = {};
  bool isSending = false;
  bool showSuccessMsg = false;
  DateTime? _lastTapTimestamp;
  bool isLocationFetched = false;
  List<String> sentEventIds = [];
  bool load = false;
  List<Map<String, dynamic>> dates = [];
  List<DateTime> projectDates = [];
  String? selectedStatus;
  bool isRequestValid = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController requestController = TextEditingController();
  late String _mapStyle;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
      isMapLoading = true;
    });
    WidgetsBinding.instance.addObserver(this);
    _getCurrentLocation(context);
    GetProfile();
    checkLikeStatus();
    // businesssearchapi();
    categorieslistapi();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(userName: '', selected: 1),
            ),
          );
        });
      }
    }
  }

  void _addCurrentLocationMarker() {
    if (AppLat.isNotEmpty && AppLon.isNotEmpty) {
      double latitude = double.tryParse(AppLat) ?? 0.0;
      double longitude = double.tryParse(AppLon) ?? 0.0;

      if (latitude != 0.0 && longitude != 0.0) {
        Marker currentLocationMarker = Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(latitude, longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: "My Location",
            snippet: "You are here",
          ),
        );

        setState(() {
          _markers.add(currentLocationMarker);
        });
      }
    }
  }

  void moveToLocation() {
    if (AppLat.isNotEmpty && AppLon.isNotEmpty) {
      double latitude = double.tryParse(AppLat) ?? 0.0;
      double longitude = double.tryParse(AppLon) ?? 0.0;

      if (latitude != 0.0 && longitude != 0.0) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 20.0),
        );

        _loadSelectedUserMarker();
      } else {}
    } else {}
  }

  Future<void> _loadSelectedUserMarker() async {
    if (businessprofileModel?.data == null ||
        businessprofileModel!.data!.isEmpty ||
        selectedUserId.isEmpty) {
      setState(() => isMapLoading = false);
      return;
    }

    Data1? selectedUser = businessprofileModel!.data!.firstWhere(
      (data) => data.id.toString() == selectedUserId,
      orElse: () => Data1(),
    );

    if (selectedUser.latitude == null || selectedUser.longitude == null) {
      _loadMarkers();
      return;
    }

    double lat = double.parse(selectedUser.latitude!);
    double lon = double.parse(selectedUser.longitude!);

    String profileImage = _getBusinessLogoForProfile(
      selectedUser.id,
      selectedUser.logo,
    );

    bool hasStory = selectedUser.featuredPosts?.isNotEmpty == true;

    BitmapDescriptor icon = await getCustomMarker(
      profileImage,
      size: 120,
      hasStory: selectedUser.featuredPosts?.isNotEmpty == true,
      storyPreviewUrl: selectedUser.featuredPosts?.first.file,
    );

    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId("selected_$selectedUserId"),
          position: LatLng(lat, lon),
          icon: icon,
          anchor: hasStory ? const Offset(0.5, 0.8) : const Offset(0.5, 0.5),
          onTap: () => _handleMarkerTap(selectedUser),
        ),
      };
      isMapLoading = false;
    });
  }

  void _showUserProfile(Data1? user) {
    if (user == null) return;

    BussinessViewProfile(user.id.toString());
  }

  void checkLikeStatus() async {
    if (busnessviewmodal?.data?.business?.id != null) {
      bool isLiked = await getLikeStatus(
        busnessviewmodal!.data!.business!.id!.toString(),
      );
      setState(() {
        busnessviewmodal?.data?.isLiked = isLiked;
      });
    }
  }

  String _getBusinessLogoForProfile(int? profileId, String? fallbackLogo) {
    if (busnessviewmodal?.data?.business?.id == profileId &&
        busnessviewmodal?.data?.business?.logo?.isNotEmpty == true) {
      return busnessviewmodal!.data!.business!.logo!;
    }

    return fallbackLogo?.isNotEmpty == true
        ? fallbackLogo!
        : "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png";
  }

  Future<void> _loadMarkers() async {
    if (businessprofileModel?.data == null ||
        businessprofileModel!.data!.isEmpty) {
      setState(() => isMapLoading = false);
      return;
    }

    setState(() {
      isMapLoading = false;
    });

    Set<Marker> markers = {};
    Map<String, List<Data1>> locationGroups = {};

    // Current location marker ને directly _markers માં ઉમેરો
    if (AppLat.isNotEmpty && AppLon.isNotEmpty) {
      double currentLat = double.tryParse(AppLat) ?? 0.0;
      double currentLon = double.tryParse(AppLon) ?? 0.0;

      if (currentLat != 0.0 && currentLon != 0.0) {
        _markers.add(
          Marker(
            markerId: const MarkerId("current_location"),
            position: LatLng(currentLat, currentLon),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
            infoWindow: const InfoWindow(title: "My Location"),
            zIndex: 1,
          ),
        );
      }
    }

    for (var data in businessprofileModel!.data!) {
      if (data.latitude != null && data.longitude != null) {
        String locationKey = "${data.latitude},${data.longitude}";
        locationGroups.putIfAbsent(locationKey, () => []);
        locationGroups[locationKey]!.add(data);
      }
    }

    final int batchSize = 5;
    final List<MapEntry<String, List<Data1>>> entries =
        locationGroups.entries.toList();

    int processedCount = 0;
    int currentBatchSize =
        (entries.length < batchSize) ? entries.length : batchSize;

    List<Future<Marker>> firstBatchFutures = [];

    for (int i = 0; i < currentBatchSize; i++) {
      final entry = entries[i];
      double lat = double.parse(entry.value.first.latitude ?? "0.0");
      double lon = double.parse(entry.value.first.longitude ?? "0.0");
      List<Data1> profiles = entry.value;
      int? profileId = profiles.first.id;

      String profileImage = _getBusinessLogoForProfile(
        profileId,
        profiles.first.logo,
      );
      bool hasStory = profiles.first.featuredPosts?.isNotEmpty == true;
      String? storyPreviewUrl =
          hasStory ? profiles.first.featuredPosts?.first.file : null;

      firstBatchFutures.add(
        Future(() async {
          final iconFutures = [
            profiles.length > 1
                ? _getClusterMarker(profiles.length, profileImage)
                : getCustomMarker(
                  profileImage,
                  size: 100,
                  hasStory: hasStory,
                  storyPreviewUrl: storyPreviewUrl,
                ),
          ];

          final results = await Future.wait(iconFutures);
          BitmapDescriptor finalIcon = results[0];

          return Marker(
            markerId: MarkerId(entry.key),
            position: LatLng(lat, lon),
            icon: finalIcon,
            onTap: () => _expandMarkers(lat, lon, profiles),
            zIndex: 2, // Business markers have lower zIndex
          );
        }),
      );

      processedCount++;
    }

    final firstBatchMarkers = await Future.wait(firstBatchFutures);
    if (mounted) {
      setState(() {
        _markers.addAll(
          firstBatchMarkers,
        ); // Add to existing markers instead of replacing
      });
    }

    while (processedCount < entries.length) {
      List<Future<Marker>> batchFutures = [];
      int remainingCount = entries.length - processedCount;
      int nextBatchSize =
          (remainingCount < batchSize) ? remainingCount : batchSize;

      for (int i = 0; i < nextBatchSize; i++) {
        final entry = entries[processedCount + i];
        double lat = double.parse(entry.value.first.latitude ?? "0.0");
        double lon = double.parse(entry.value.first.longitude ?? "0.0");
        List<Data1> profiles = entry.value;
        int? profileId = profiles.first.id;

        String profileImage = _getBusinessLogoForProfile(
          profileId,
          profiles.first.logo,
        );
        bool hasStory = profiles.first.featuredPosts?.isNotEmpty == true;
        String? storyPreviewUrl =
            hasStory ? profiles.first.featuredPosts?.first.file : null;

        batchFutures.add(
          Future(() async {
            final iconFutures = [
              profiles.length > 1
                  ? _getClusterMarker(profiles.length, profileImage)
                  : getCustomMarker(
                    profileImage,
                    size: 100,
                    hasStory: hasStory,
                    storyPreviewUrl: storyPreviewUrl,
                  ),
            ];

            final results = await Future.wait(iconFutures);
            BitmapDescriptor finalIcon = results[0];

            return Marker(
              markerId: MarkerId(entry.key),
              position: LatLng(lat, lon),
              icon: finalIcon,
              onTap: () => _expandMarkers(lat, lon, profiles),
              zIndex: 2,
            );
          }),
        );
      }

      final batchMarkers = await Future.wait(batchFutures);
      setState(() {
        _markers.addAll(batchMarkers);
      });

      processedCount += nextBatchSize;

      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  void _onCameraIdle() {
    mapController.getZoomLevel().then((zoom) {
      if (zoom < 16.0) {
        _loadMarkers();
      }
    });
  }

  Future<BitmapDescriptor> _getClusterMarker(
    int count,
    String profileImageUrl,
  ) async {
    const int size = 120;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint();

    final Uint8List imgBytes = await getBytesFromCanvas(profileImageUrl, size);
    final ui.Codec codec = await ui.instantiateImageCodec(
      imgBytes,
      targetWidth: size,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    canvas.drawImage(image, const Offset(0, 0), paint);

    double countCircleX = size - 30;
    double countCircleY = 17;

    paint.color = Colors.black;
    canvas.drawCircle(Offset(countCircleX, countCircleY), 18, paint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: "+$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(countCircleX - 10, countCircleY - 10));

    final ui.Image img = await recorder.endRecording().toImage(size, size);
    final ByteData? byteData = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void _expandMarkers(double lat, double lon, List<Data1> profiles) async {
    await mapController.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lon), 17.0),
    );
    Set<Marker> expandedMarkers = {};

    for (int i = 0; i < profiles.length; i++) {
      double angle = (2 * pi * i) / profiles.length;
      double offsetLat = lat + 0.0001 * cos(angle);
      double offsetLon = lon + 0.0001 * sin(angle);
      int profileSize =
          (selectedUserId == profiles[i].id.toString()) ? 300 : 150;

      String profileImage = _getBusinessLogoForProfile(
        profiles[i].id,
        profiles[i].logo,
      );
      bool hasStory = profiles[i].featuredPosts?.isNotEmpty == true;
      String? storyPreviewUrl =
          hasStory ? profiles[i].featuredPosts?.first.file : null;

      BitmapDescriptor combinedIcon = await getCustomMarker(
        profileImage,
        size: profileSize,
        hasStory: hasStory,
        storyPreviewUrl: storyPreviewUrl,
        showOnlyProfile: false,
        showOnlyStory: false,
      );

      expandedMarkers.add(
        Marker(
          markerId: MarkerId("combined_${profiles[i].id}"),
          position: LatLng(offsetLat, offsetLon),
          icon: combinedIcon,
          anchor: const Offset(0.5, 0.5),
          onTap: () => _handleMarkerTap(profiles[i]),
          zIndex: 1,
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers.addAll(expandedMarkers);
    });
  }

  Future<BitmapDescriptor> getCustomMarker(
    String imageUrl, {
    int size = 100,
    bool hasStory = false,
    String? storyPreviewUrl,
    bool showOnlyStory = false,
    bool showOnlyProfile = false,
  }) async {
    try {
      final Uint8List markerIcon = await getBytesFromCanvas(
        imageUrl,
        size,
        hasStory: hasStory,
        storyPreviewUrl: storyPreviewUrl,
        showOnlyStory: showOnlyStory,
        showOnlyProfile: showOnlyProfile,
      );
      return BitmapDescriptor.fromBytes(markerIcon);
    } catch (e) {
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<Uint8List> getBytesFromCanvas(
    String url,
    int size, {
    bool hasStory = false,
    String? storyPreviewUrl,
    bool showOnlyStory = false,
    bool showOnlyProfile = false,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    final double logoRadius = size / 2;

    final double storySize = size * 0.65;
    final double storyRadius = storySize / 2;

    final double verticalSpacing = size * 0.15;

    final double canvasHeight =
        hasStory ? (size + storySize + verticalSpacing) : size.toDouble();
    final double canvasWidth = size.toDouble();

    final Offset logoCenter = Offset(
      size / 2,
      hasStory ? (canvasHeight - logoRadius) : logoRadius,
    );

    final Offset storyCenter =
        hasStory
            ? Offset(size / 2, storySize * 0.5)
            : Offset(size / 2, logoRadius);

    paint.color = Colors.white;
    canvas.drawCircle(logoCenter, logoRadius, paint);

    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
      final Uint8List imgBytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        imgBytes,
        targetWidth: size,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      canvas.save();
      final Path logoPath =
          Path()..addOval(
            Rect.fromCircle(center: logoCenter, radius: logoRadius - 3),
          );
      canvas.clipPath(logoPath);

      canvas.drawImage(
        image,
        Offset(logoCenter.dx - logoRadius, logoCenter.dy - logoRadius),
        Paint(),
      );
      canvas.restore();
    } catch (e) {}

    if (hasStory && storyPreviewUrl?.isNotEmpty == true) {
      paint.color = Colors.green;
      paint.strokeWidth = 4.0;
      canvas.drawCircle(storyCenter, storyRadius, paint);

      paint.color = Colors.white;
      canvas.drawCircle(storyCenter, storyRadius - 3, paint);

      try {
        final ByteData data = await NetworkAssetBundle(
          Uri.parse(storyPreviewUrl!),
        ).load("");
        final Uint8List imgBytes = data.buffer.asUint8List();
        final ui.Codec codec = await ui.instantiateImageCodec(
          imgBytes,
          targetWidth: storySize.toInt(),
        );
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final ui.Image storyImage = frameInfo.image;

        canvas.save();
        final Path storyPath =
            Path()..addOval(
              Rect.fromCircle(center: storyCenter, radius: storyRadius - 5),
            );
        canvas.clipPath(storyPath);

        canvas.drawImage(
          storyImage,
          Offset(
            storyCenter.dx - storyRadius + 5,
            storyCenter.dy - storyRadius + 5,
          ),
          Paint(),
        );
        canvas.restore();

        final Path trianglePath = Path();
        final double triangleHeight = verticalSpacing * 0.9;
        final double triangleWidth = triangleHeight * 0.9;

        trianglePath.moveTo(storyCenter.dx, storyCenter.dy + storyRadius);
        trianglePath.lineTo(
          storyCenter.dx - triangleWidth,
          storyCenter.dy + storyRadius + triangleHeight,
        );
        trianglePath.lineTo(
          storyCenter.dx + triangleWidth,
          storyCenter.dy + storyRadius + triangleHeight,
        );
        trianglePath.close();

        paint.color = Colors.green;
        canvas.drawPath(trianglePath, paint);
      } catch (e) {}
    }

    final ui.Image img = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final ByteData? byteData = await img.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  bool marker = false;
  bool _showingStory = false;

  void _handleMarkerTap(Data1 user) {
    bool hasStory = user.featuredPosts?.isNotEmpty == true;

    if (hasStory) {
      if (_showingStory) {
        setState(() {
          marker = true;
          _showingStory = false;
        });
        _showUserStory(user.id);
      } else {
        setState(() {
          marker = false;
          _showingStory = true;
        });
        _showUserProfile(user);
      }
    } else {
      setState(() {
        marker = false;
      });
      _showUserProfile(user);
    }
  }

  void _showUserStory(int? userId) {
    if (userId == null) return;

    try {
      Get.to(StoryViewerScreen(userId: userId));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening story: $e')));
    }
  }

  double fallbackLatitude = 51.5072;
  double fallbackLongitude = 0.1276;

  Future<void> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showPermissionDialog(
        context,
        title: "Location Services",
        message: "Please enable location services to use map features.",
        openSettings: true,
      );
      _setFallbackLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog(
          context,
          title: "Location Services",
          message:
              "To provide full functionality and show nearby building services, Wavee AI requires access to your location. You can enable location in Settings.",
          openSettings: true,
          showCancel: true,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog(
        context,
        title: "Location Services",
        message:
            "To provide full functionality and show nearby building services, Wavee AI requires access to your location. You can enable location in Settings.",
        openSettings: true,
        showCancel: true,
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      AppLat = position.latitude.toString();
      AppLon = position.longitude.toString();

      setState(() {
        isLocationFetched = true;
      });
      _addCurrentLocationMarker();
      getCityName(position.latitude, position.longitude);
    } catch (e) {
      _showPermissionDialog(
        context,
        title: "Location Services",
        message:
            "To provide full functionality and show nearby building services, Wavee AI requires access to your location. You can enable location in Settings.",
        showCancel: true,
      );
    }

    setState(() {
      isMapLoading = false;
    });
  }

  void _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool openSettings = false,
    bool showCancel = false,
  }) {
    if (_isDialogVisible) return;

    _isDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: 16,
          ),
          titlePadding: const EdgeInsets.only(top: 16, left: 24, right: 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppConstants.manrope,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _isDialogVisible = false;
                    _setFallbackLocation();
                  },
                ),
              ).paddingOnly(right: 2.w),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(fontFamily: AppConstants.manrope, fontSize: 16.sp),
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 12,
            left: 16,
            right: 16,
          ),
          actions: [
            Row(
              children: [
                if (showCancel)
                  Expanded(
                    child: batan(
                      title: "Cancel",
                      route: () {
                        Navigator.of(context).pop();
                        _isDialogVisible = false;
                        _setFallbackLocation();
                      },
                      color: Colors.white,
                      fontcolor: Colors.black,
                      height: 5.h,
                      fontsize: 18.sp,
                      radius: 12.0,
                      width: double.infinity,
                    ),
                  ),
                if (openSettings && showCancel) const SizedBox(width: 12),
                if (openSettings)
                  Expanded(
                    child: batan(
                      title: "Open Settings",
                      route: () async {
                        Navigator.of(context).pop();
                        _isDialogVisible = false;

                        await Geolocator.openAppSettings();
                        await Future.delayed(
                          const Duration(seconds: 1),
                        ); // give time to apply

                        LocationPermission permission =
                            await Geolocator.checkPermission();
                      },
                      color: AppColors.maincolor,
                      fontcolor: AppColors.white,
                      height: 5.h,
                      fontsize: 18.sp,
                      radius: 12.0,
                      width: double.infinity,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    ).then((_) {
      _isDialogVisible = false;
    });
  }

  bool _isDialogVisible = false;

  void _setFallbackLocation() {
    AppLat = fallbackLatitude.toString();
    AppLon = fallbackLongitude.toString();

    setState(() {
      isLocationFetched = true;
      isMapLoading = false;
    });
  }

  String? city;

  Future<void> getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          city = placemarks[0].locality;
        });
        BussinessProfile();

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final String _darkMapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

  final String _lightMapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "off" }
    ]
  }
]
''';

  // 3. _applyMapStyle મેથડમાં ફેરફાર
  // void _applyMapStyle(bool isDark) {
  //   if (mapController != null) {
  //     try {
  //       // Clear any previous style first
  //       mapController!.setMapStyle(null);
  //
  //       // Add small delay
  //       Future.delayed(Duration(milliseconds: 50), () {
  //         if (mapController != null) {
  //           // Apply appropriate style
  //           if (isDark) {
  //             mapController!.setMapStyle(_darkMapStyle);
  //           } else {
  //             mapController!.setMapStyle(_lightMapStyle);
  //           }
  //         }
  //       });
  //     } catch (e) {
  //       print("Error applying map style: $e");
  //     }
  //   }
  // }

  @override
  void didUpdateWidget(covariant CommunityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if (oldWidget != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       _applyMapStyle(
    //         Provider.of<ThemeController>(context, listen: false).isDark,
    //       );
    //     }
    //   });
    // }
  }

  bool isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    return Scaffold(
      bottomNavigationBar: Obx(
        () =>
            BottomBar(selected: 2, chatCount: countsController.chatCount.value),
      ),
      backgroundColor:
          theme.isDark ? const Color(0xf01A1A1A) : const Color(0xFFF0F2F5),

      body: WillPopScope(
        onWillPop: () async {
          Get.offAll(() => HomePage(selected: 1, userName: ""));
          return false;
        },
        child: Stack(
          children: [
            // isLocationFetched
            //     ?
            // GoogleMap(
            //       key: ValueKey(theme.isDark),
            //       // આ લાઇન જરૂરી છે
            //       onMapCreated: (GoogleMapController controller) async {
            //         mapController = controller;
            //         _customInfoWindowController.googleMapController =
            //             controller;
            //
            //         // Map create થયા પછી તરત જ style અપ્લાય કરો
            //         await Future.delayed(Duration(milliseconds: 300));
            //         _applyMapStyle(theme.isDark);
            //       },
            //       onCameraIdle: _onCameraIdle,
            //       myLocationButtonEnabled: false,
            //       zoomControlsEnabled: false,
            //       compassEnabled: false,
            //       indoorViewEnabled: true,
            //       mapToolbarEnabled: false,
            //       myLocationEnabled: false,
            //       zoomGesturesEnabled: true,
            //       mapType: MapType.normal,
            //       initialCameraPosition: CameraPosition(
            //         target: LatLng(double.parse(AppLat), double.parse(AppLon)),
            //         zoom: 14.0,
            //       ),
            //       markers: _markers,
            //       onTap: (_) {
            //         _customInfoWindowController.hideInfoWindow!();
            //       },
            //       onCameraMove: (position) {
            //         _customInfoWindowController.onCameraMove!();
            //       },
            //     )
            //     : const Center(
            //       child: CircularProgressIndicator(),
            //     ), // or fallback UI
            isLocationFetched
                ? AnimatedOpacity(
                  // જો મેપ રેડી હોય તો જ દેખાશે, નહીંતર ટ્રાન્સપરન્ટ રહેશે
                  opacity: isMapReady ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500), // સ્મૂધ એનિમેશન
                  child: GoogleMap(
                    key: ValueKey(theme.isDark),
                    style: theme.isDark ? _darkMapStyle : _lightMapStyle,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      _customInfoWindowController.googleMapController =
                          controller;

                      // મેપ બની ગયા પછી થોડીક જ વારમાં તેને વિઝિબલ કરો
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (mounted) {
                          setState(() {
                            isMapReady = true;
                          });
                        }
                      });
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    indoorViewEnabled: true,
                    mapToolbarEnabled: false,
                    myLocationEnabled: false,
                    zoomGesturesEnabled: true,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        double.parse(AppLat),
                        double.parse(AppLon),
                      ),
                      zoom: 14.0,
                    ),
                    markers: _markers,
                  ),
                )
                : const SizedBox(),
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 27.h,
              width: 150,
              offset: 50,
            ),
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(ViewProfile(id: loginModel?.data?.user?.id));
                    },
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: profileModel?.data?.user?.profile ?? '',
                        imageBuilder:
                            (context, imageProvider) => Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        placeholder:
                            (context, url) => Container(
                              width: 10.w,
                              height: 10.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                              ),
                              child: SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.maincolor,
                                  ),
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              width: 10.w,
                              height: 10.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                image: const DecorationImage(
                                  image: AssetImage(
                                    "assets/images/waveeLogoShort.png",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const ThemeToggleButton().paddingOnly(bottom: 0.5.h),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showSearchBottomSheet(context);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                theme.isDark
                                    ? const Color(0xffbdab82)
                                    : Colors.white,
                            width: 3.sp,
                          ),
                          color:
                              theme.isDark
                                  ? const Color(0xff1c1d1c)
                                  : Colors.white,
                        ),
                        child: Icon(
                          Icons.search,
                          color:
                              theme.isDark
                                  ? const Color(0xffbdab82)
                                  : Colors.black87,
                          size: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    SizedBox(width: 1.w),
                    GestureDetector(
                      onTap: () {
                        getlikeapi();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        // width: 33.w,
                        // height: 5.h,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            ui.Radius.circular(20),
                          ),
                          border: Border.all(
                            color:
                                theme.isDark
                                    ? const Color(
                                      0xFFCDBA81,
                                    ).withValues(alpha: 0.15)
                                    : Colors.white,
                            width: 3.sp,
                          ),
                          color:
                              theme.isDark
                                  ? const Color(0xff1c1d1c)
                                  : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color:
                                  theme.isDark
                                      ? const Color(0xffbdab82)
                                      : AppColors.lightText,
                              size: 17.sp,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Favourites",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: AppConstants.manrope,
                                fontWeight: FontWeight.bold,
                                color:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    GestureDetector(
                      onTap: () {
                        getvisitedapi();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        // width: 29.w,
                        // height: 5.h,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            ui.Radius.circular(20),
                          ),
                          border: Border.all(
                            color:
                                theme.isDark
                                    ? const Color(
                                      0xFFCDBA81,
                                    ).withValues(alpha: 0.15)
                                    : Colors.white,
                            width: 3.sp,
                          ),
                          color:
                              theme.isDark
                                  ? const Color(0xff1c1d1c)
                                  : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color:
                                  theme.isDark
                                      ? const Color(0xffbdab82)
                                      : AppColors.lightText,
                              size: 17.sp,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Visited",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: AppConstants.manropeBold,
                                fontWeight: FontWeight.bold,
                                color:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Wrap(
                      spacing: 8,
                      runSpacing: 7,
                      children: [
                        for (
                          int i = 0;
                          i < (categoriesModel?.data?.length ?? 0);
                          i++
                        )
                          GestureDetector(
                            onTap: () {
                              String categoryId =
                                  categoriesModel?.data?[i].id.toString() ?? "";
                              String categoryName =
                                  categoriesModel?.data?[i].categoryName ?? "";
                              String categoryImage =
                                  categoriesModel?.data?[i].img ?? "";

                              CategoriesProfileView(
                                categoryId,
                                categoryName,
                                categoryImage,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              height: 5.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      theme.isDark
                                          ? const Color(
                                            0xFFCDBA81,
                                          ).withValues(alpha: 0.15)
                                          : Colors.white,
                                  width: 3.sp,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                color:
                                    theme.isDark
                                        ? const Color(0xff1c1d1c)
                                        : Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 3.5.h,
                                    width: 3.5.h,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      // color: getCategoryColor(
                                      //   categoriesModel
                                      //           ?.data?[i]
                                      //           .categoryName ??
                                      //       "",
                                      // ),
                                    ),
                                    child: Center(
                                      child: ClipOval(
                                        child: Image.network(
                                          categoriesModel?.data?[i].img ?? "",
                                          height: 2.2.h,
                                          width: 2.2.h,
                                          fit: BoxFit.cover,
                                          color:
                                              theme.isDark
                                                  ? const Color(0xffbdab82)
                                                  : AppColors.lightText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    categoriesModel?.data?[i].categoryName ??
                                        "",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontFamily: AppConstants.manropeBold,

                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : AppColors.lightText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (!isMapReady)
              Container(
                color:
                    theme.isDark
                        ? const Color(0xff1A1A1A)
                        : const Color(0xFFF0F2F5),
                child: const Center(child: Loader()),
              ),
            if (isMapLoading)
              Positioned.fill(
                child: Container(
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.maincolor,
                    ),
                  ),
                ),
              ),
            isSending
                ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Center(child: Loader()),
                  ),
                )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? '',
    };

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().profileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(response.data);
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void _showFavouriteBottomSheet() async {
    final theme = Provider.of<ThemeController>(context, listen: false);

    if (_isBottomSheetOpen) return;

    _isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 1.0,
          minChildSize: 0.3,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        theme.isDark ? const Color(0xff1a1a1a) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : const Color(0xfff5f5f5),
                                child: Icon(
                                  Icons.favorite,
                                  color:
                                      theme.isDark ? Colors.white : Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Favourites",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manropeBold,
                                    ),
                                  ),
                                  Text(
                                    "${getlikeModal?.data?.length ?? "No"} Favourites",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.sp,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color:
                                  theme.isDark
                                      ? const Color(0xff272727)
                                      : AppColors.blackColor,
                              border: Border.all(
                                color:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : Colors.black87,
                                width: 0.2.w,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color:
                                      theme.isDark
                                          ? const Color(0xffbdab82)
                                          : Colors.white,
                                  size: 5.w,
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child:
                            (getlikeModal?.data == null ||
                                    getlikeModal!.data!.isEmpty)
                                ? const Center(
                                  child: Text(
                                    "No Favourites Added!",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.zero,
                                  itemCount: getlikeModal?.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    bool isFirst = index == 0;
                                    bool isLast =
                                        index ==
                                        (getlikeModal?.data?.length ?? 1) - 1;

                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.back();
                                            BussinessViewProfile(
                                              (getlikeModal
                                                      ?.data?[index]
                                                      .businessId)
                                                  .toString(),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  theme.isDark
                                                      ? const Color(0xff272727)
                                                      : const Color(0xfff5f5f5),
                                              borderRadius: BorderRadius.only(
                                                topLeft:
                                                    isFirst
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                                topRight:
                                                    isFirst
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                                bottomLeft:
                                                    isLast
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                                bottomRight:
                                                    isLast
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage:
                                                      (getlikeModal
                                                                  ?.data?[index]
                                                                  .business
                                                                  ?.logo
                                                                  ?.isEmpty ??
                                                              true)
                                                          ? const AssetImage(
                                                            "assets/images/waveeLogoShort.png",
                                                          )
                                                          : CachedNetworkImageProvider(
                                                                getlikeModal
                                                                        ?.data?[index]
                                                                        .business
                                                                        ?.logo ??
                                                                    "",
                                                              )
                                                              as ImageProvider,
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getlikeModal
                                                                ?.data?[index]
                                                                .business
                                                                ?.businessName ??
                                                            "N/A",
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              theme.isDark
                                                                  ? const Color(
                                                                    0xffbdab82,
                                                                  )
                                                                  : Colors
                                                                      .black87,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manropeBold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        "${(getlikeModal?.data?[index].distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: Colors.grey,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    _unlikeBusiness(
                                                      index,
                                                      setState,
                                                    );
                                                  },
                                                  child: const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                    size: 28,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isLast)
                                          Divider(
                                            color: Colors.grey[300],
                                            thickness: 1,
                                            height: 0,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  void _unlikeBusiness(int index, StateSetter setState) async {
    // Store the item data in case we need to revert
    final businessToRemove = getlikeModal?.data?[index];
    final businessId = businessToRemove?.businessId;

    // Immediate UI update - remove from list
    setState(() {
      getlikeModal?.data?.removeAt(index);
    });

    // API call
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': businessId.toString(),
      'is_like': "0",
    };

    try {
      final response = await CommunityProvider().businessLikeApi(data);

      if (response.statusCode != 200) {
        // If API fails, add the item back to the list
        setState(() {
          getlikeModal?.data?.insert(index, businessToRemove!);
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to remove from favorites"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print("Sucess Favourites Removed");
      }
    } catch (error) {
      // If API call fails, add the item back to the list
      setState(() {
        getlikeModal?.data?.insert(index, businessToRemove!);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showvisitedBottomSheet() async {
    final theme = Provider.of<ThemeController>(context, listen: false);

    if (_isBottomSheetOpen) return;

    _isBottomSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        theme.isDark ? const Color(0xff1a1a1a) : Colors.white,

                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade300,

                                child: Icon(
                                  Icons.location_on,
                                  color:
                                      theme.isDark
                                          ? const Color(0xffbdab82)
                                          : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Recently Visited",
                                    style: TextStyle(
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : Colors.black87,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppConstants.manropeBold,
                                    ),
                                  ),
                                  Text(
                                    "${getvisitedModal?.data?.length ?? "No"}  Recently Visited",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.sp,
                                      fontFamily: AppConstants.manrope,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color:
                                  theme.isDark
                                      ? const Color(0xff272727)
                                      : Colors.black,
                              border: Border.all(
                                color:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : Colors.black,
                                width: 0.2.w,
                              ),

                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color:
                                      theme.isDark
                                          ? const Color(0xffbdab82)
                                          : Colors.white,
                                  size: 5.w,
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child:
                            (getvisitedModal?.data == null ||
                                    getvisitedModal!.data!.isEmpty)
                                ? const Center(
                                  child: Text(
                                    "No Businesses Found!",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  itemCount: getvisitedModal?.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    bool isFirst = index == 0;
                                    bool isLast =
                                        index ==
                                        (getvisitedModal?.data?.length ?? 1) -
                                            1;

                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.back();
                                            BussinessViewProfile(
                                              (getvisitedModal
                                                      ?.data?[index]
                                                      .businessId)
                                                  .toString(),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  theme.isDark
                                                      ? const Color(0xff272727)
                                                      : const Color(0xfff5f5f5),

                                              borderRadius: BorderRadius.only(
                                                topLeft:
                                                    isFirst
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                                topRight:
                                                    isFirst
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                                bottomLeft:
                                                    isLast
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                                bottomRight:
                                                    isLast
                                                        ? const Radius.circular(
                                                          15,
                                                        )
                                                        : Radius.zero,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage:
                                                      (getvisitedModal
                                                                  ?.data?[index]
                                                                  .business
                                                                  ?.logo
                                                                  ?.isEmpty ??
                                                              true)
                                                          ? const AssetImage(
                                                            "assets/images/waveeLogoShort.png",
                                                          )
                                                          : CachedNetworkImageProvider(
                                                                getvisitedModal
                                                                        ?.data?[index]
                                                                        .business
                                                                        ?.logo ??
                                                                    "",
                                                              )
                                                              as ImageProvider,
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        getvisitedModal
                                                                ?.data?[index]
                                                                .business
                                                                ?.businessName ??
                                                            "N/A",
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              theme.isDark
                                                                  ? const Color(
                                                                    0xffbdab82,
                                                                  )
                                                                  : Colors
                                                                      .black87,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manropeBold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        "${(getvisitedModal?.data?[index].distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: Colors.grey,
                                                          fontFamily:
                                                              AppConstants
                                                                  .manrope,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isLast)
                                          Divider(
                                            color: Colors.grey[300],
                                            thickness: 1,
                                            height: 1,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  Future<void> _showcategoriesdBottomSheet(
    ViewCategoriesModel? viewcategoriesmodel,
    String categoryName,
    String categoryImage,
  ) async {
    if (_isBottomSheetOpen) return;
    final theme = Provider.of<ThemeController>(context, listen: false);

    _isBottomSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        theme.isDark ? const Color(0xff1a1a1a) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  height: 5.h,
                                  width: 5.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: getCategoryColor(categoryName),
                                  ),
                                  child: Center(
                                    child: ClipOval(
                                      child:
                                          categoryImage.isNotEmpty
                                              ? Image.network(
                                                categoryImage,
                                                height: 3.h,
                                                width: 3.h,
                                                fit: BoxFit.cover,
                                              )
                                              : const Icon(
                                                Icons.category_rounded,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categoryName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "${viewcategoriesmodel?.data?.length ?? "No"} $categoryName",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: const Color(0xff272727),
                              border: Border.all(
                                color:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : const Color(0xfff5f5f5),
                                width: 0.2.w,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color:
                                      theme.isDark
                                          ? const Color(0xffbdab82)
                                          : Colors.white,
                                  size: 5.w,
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child:
                            (viewcategoriesmodel?.data == null ||
                                    viewcategoriesmodel!.data!.isEmpty)
                                ? const Center(
                                  child: Text(
                                    "No Businesses Found!",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  itemCount:
                                      viewcategoriesmodel.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    bool isFirstItem = index == 0;
                                    bool isLastItem =
                                        index ==
                                        (viewcategoriesmodel.data?.length ??
                                                0) -
                                            1;

                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.back();
                                            BussinessViewProfile(
                                              (viewcategoriesmodel
                                                      .data?[index]
                                                      .id)
                                                  .toString(),
                                            );
                                            print(
                                              "viewcategoriesmodel?.data?[index].id${viewcategoriesmodel.data?[index].id}",
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                  isFirstItem ? 15 : 0,
                                                ),
                                                topRight: Radius.circular(
                                                  isFirstItem ? 15 : 0,
                                                ),
                                                bottomLeft: Radius.circular(
                                                  isLastItem ? 15 : 0,
                                                ),
                                                bottomRight: Radius.circular(
                                                  isLastItem ? 15 : 0,
                                                ),
                                              ),
                                              color:
                                                  theme.isDark
                                                      ? const Color(0xff272727)
                                                      : Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage:
                                                      (viewcategoriesmodel
                                                                  .data?[index]
                                                                  .logo
                                                                  ?.isEmpty ??
                                                              true)
                                                          ? const AssetImage(
                                                            "assets/images/waveeLogoShort.png",
                                                          )
                                                          : CachedNetworkImageProvider(
                                                                viewcategoriesmodel
                                                                        .data?[index]
                                                                        .logo ??
                                                                    "",
                                                              )
                                                              as ImageProvider,
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        viewcategoriesmodel
                                                                .data?[index]
                                                                .businessName ??
                                                            "N/A",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              theme.isDark
                                                                  ? const Color(
                                                                    0xffbdab82,
                                                                  )
                                                                  : Colors
                                                                      .black87,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      const SizedBox(height: 3),
                                                      Text(
                                                        "${(viewcategoriesmodel.data?[index].distance ?? 0).toStringAsFixed(2)} Miles",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isLastItem)
                                          Divider(
                                            color: Colors.grey[300],
                                            thickness: 1,
                                            height: 1,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  void _showSearchBottomSheet(BuildContext context) {
    bool isSearching = false;
    search.clear();
    final theme = Provider.of<ThemeController>(context, listen: false);

    List<dynamic> filteredList = List.from(businessprofileModel?.data ?? []);
    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        theme.isDark ? const Color(0xff1a1a1a) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 5.h,
                              margin: EdgeInsets.only(left: 1.w),
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color:
                                    theme.isDark
                                        ? const Color(0xff272727)
                                        : const Color(0xfff5f5f5),
                                border: Border.all(
                                  color:
                                      theme.isDark
                                          ? const Color(0xffbdab82)
                                          : const Color(0xffe8eaee),
                                  width: 0.2.w,
                                ),
                              ),
                              child: TextField(
                                controller: search,
                                decoration: InputDecoration(
                                  hintText: "Search For Business",
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontFamily: AppConstants.manrope,
                                    fontSize: 16.sp,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color:
                                        theme.isDark
                                            ? const Color(0xffbdab82)
                                            : Colors.black87,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      theme.isDark
                                          ? const Color(0xffbdab82)
                                          : Colors.black87,
                                  fontFamily: AppConstants.manrope,
                                ),
                                onTap: () {
                                  setState(() {
                                    isSearching = true;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      filteredList = List.from(
                                        businessprofileModel?.data ?? [],
                                      );
                                    } else {
                                      String searchText = value.toLowerCase();

                                      filteredList =
                                          businessprofileModel?.data?.where((
                                            businessData,
                                          ) {
                                            String businessName =
                                                (businessData.businessName ??
                                                        "")
                                                    .toLowerCase();

                                            String categoryName =
                                                (businessData
                                                            .category
                                                            ?.categoryName ??
                                                        "")
                                                    .toLowerCase();
                                            bool categoryMatch = categoryName
                                                .contains(searchText);

                                            String subCategoryName =
                                                (businessData
                                                            .subCategory
                                                            ?.subCategoryName ??
                                                        "")
                                                    .toLowerCase();
                                            bool subCategoryMatch =
                                                subCategoryName.contains(
                                                  searchText,
                                                );

                                            bool tagMatch =
                                                businessData.tags?.any(
                                                  (tag) =>
                                                      tag.name
                                                          ?.toLowerCase()
                                                          .contains(
                                                            searchText,
                                                          ) ??
                                                      false,
                                                ) ??
                                                false;

                                            String distanceString =
                                                (businessData.distance ?? 0.0)
                                                    .toStringAsFixed(1);
                                            bool distanceMatch = distanceString
                                                .contains(searchText);

                                            return businessName.contains(
                                                  searchText,
                                                ) ||
                                                categoryMatch ||
                                                subCategoryMatch ||
                                                tagMatch ||
                                                distanceMatch;
                                          }).toList() ??
                                          [];
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Container(
                          //   width: 8.w,
                          //   height: 8.w,
                          //   decoration: BoxDecoration(
                          //     color: Colors.grey[300],
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child: Center(
                          //     child:
                          //     IconButton(
                          //       icon: Icon(
                          //         Icons.close_rounded,
                          //         color: Colors.black,
                          //         size: 5.w,
                          //       ),
                          //       onPressed: () {
                          //         setState(() {
                          //           search.clear();
                          //           isSearching = false;
                          //           filteredList = List.from(
                          //             businessprofileModel?.data ?? [],
                          //           );
                          //         });
                          //         Get.back();
                          //       },
                          //       padding: EdgeInsets.zero,
                          //       constraints: const BoxConstraints(),
                          //     ),
                          //   ),
                          // ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                search.clear();
                                isSearching = false;
                                filteredList = List.from(
                                  businessprofileModel?.data ?? [],
                                );
                              });
                              Get.back();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : Colors.black87,
                                fontFamily: AppConstants.manropeBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      if (!isSearching)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            margin: EdgeInsets.only(left: 2.w),
                            child: Row(
                              children: [
                                _filterButtons(
                                  "Favourites",
                                  Icons.favorite,
                                  () {
                                    Get.back();
                                    getlikeapi();
                                  },
                                  Colors.red,
                                  Colors.black,
                                ),
                                SizedBox(width: 2.w),
                                _filterButtons(
                                  "Visited",
                                  Icons.location_on,
                                  () {
                                    Get.back();
                                    getvisitedapi();
                                  },
                                  Colors.black,
                                  Colors.black,
                                ),
                                SizedBox(width: 2.w),
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: [
                                    for (
                                      int i = 0;
                                      i < (categoriesModel?.data?.length ?? 0);
                                      i++
                                    )
                                      GestureDetector(
                                        onTap: () {
                                          String categoryId =
                                              categoriesModel?.data?[i].id
                                                  .toString() ??
                                              "";
                                          String categoryName =
                                              categoriesModel
                                                  ?.data?[i]
                                                  .categoryName ??
                                              "";
                                          String categoryImage =
                                              categoriesModel?.data?[i].img ??
                                              "";
                                          print(
                                            "categoryIdcategoryId : $categoryId",
                                          );
                                          print(
                                            "Selected Category Name: $categoryName",
                                          );
                                          Get.back();
                                          CategoriesProfileView(
                                            categoryId,
                                            categoryName,
                                            categoryImage,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color:
                                                theme.isDark
                                                    ? const Color(0xff272727)
                                                    : const Color(0xfff5f5f5),
                                            border: Border.all(
                                              color:
                                                  theme.isDark
                                                      ? const Color(0xffbdab82)
                                                      : const Color(0xfff5f5f5),
                                              width: 0.2.w,
                                            ),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl:
                                                      categoriesModel
                                                          ?.data?[i]
                                                          .img ??
                                                      "",
                                                  imageBuilder:
                                                      (
                                                        context,
                                                        imageProvider,
                                                      ) => Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                  placeholder:
                                                      (
                                                        context,
                                                        url,
                                                      ) => Container(
                                                        width: 20,
                                                        height: 20,
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            const CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            const BoxDecoration(
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                        child: const Icon(
                                                          Icons.person,
                                                          size: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                ),

                                                const SizedBox(width: 4),
                                                Text(
                                                  categoriesModel
                                                          ?.data?[i]
                                                          .categoryName ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        theme.isDark
                                                            ? const Color(
                                                              0xffbdab82,
                                                            )
                                                            : Colors.black87,
                                                    fontFamily:
                                                        AppConstants
                                                            .manropeBold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child:
                            isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : (filteredList.isEmpty)
                                ? Container(
                                  margin: EdgeInsets.only(top: 6.h),
                                  child: Text(
                                    "No business found",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                  itemCount: filteredList.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        String businessId =
                                            filteredList.isEmpty
                                                ? BussinessViewProfile(
                                                      (businessprofileModel
                                                              ?.data?[index]
                                                              .id)
                                                          .toString(),
                                                    ) ??
                                                    ""
                                                : filteredList[index].id
                                                    .toString();

                                        print(
                                          "businessId from filteredList: $businessId",
                                        );

                                        Get.back();
                                        BussinessViewProfile(businessId);

                                        print(
                                          "Navigating to business details with ID: $businessId",
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(1.w),
                                        decoration: BoxDecoration(
                                          color:
                                              theme.isDark
                                                  ? const Color(0xff272727)
                                                  : Colors.white,
                                          // border: Border.all(
                                          //   color: Color(0xffbdab82),
                                          //   width: 0.2.w,
                                          // ),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              index == 0 ? 15 : 0,
                                            ),
                                            topRight: Radius.circular(
                                              index == 0 ? 15 : 0,
                                            ),
                                            bottomLeft: Radius.circular(
                                              index == filteredList.length - 1
                                                  ? 15
                                                  : 0,
                                            ),
                                            bottomRight: Radius.circular(
                                              index == filteredList.length - 1
                                                  ? 15
                                                  : 0,
                                            ),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            ListTile(
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      (filteredList[index]
                                                                  .profile
                                                                  ?.isNotEmpty ??
                                                              false)
                                                          ? filteredList[index]
                                                              .profile
                                                              .toString()
                                                          : "",
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      (context, url) =>
                                                          const CircularProgressIndicator(),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => const Image(
                                                        image: AssetImage(
                                                          "assets/images/waveeLogoShort.png",
                                                        ),
                                                        fit: BoxFit.cover,
                                                        width: 40,
                                                        height: 40,
                                                      ),
                                                ),
                                              ),
                                              title: Text(
                                                filteredList[index]
                                                        .businessName ??
                                                    "N/A",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      AppConstants.manropeBold,
                                                  color:
                                                      theme.isDark
                                                          ? const Color(
                                                            0xffd4d4d4,
                                                          )
                                                          : Colors.black87,
                                                ),
                                              ),
                                              subtitle: Row(
                                                children: [
                                                  Text(
                                                    (businessprofileModel
                                                            ?.data?[index]
                                                            .subStatus
                                                            ?.capitalizeFirst ??
                                                        ""),
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: const Color(
                                                        0xff656565,
                                                      ),
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3.w),
                                                  Text(
                                                    "${(filteredList[index].distance ?? 0.0).toStringAsFixed(2)} Miles",
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: const Color(
                                                        0xff656565,
                                                      ),
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: Container(
                                                width: 10.w,
                                                height: 10.w,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      theme.isDark
                                                          ? const Color(
                                                            0xff272727,
                                                          )
                                                          : const Color(
                                                            0xfff5f5f5,
                                                          ),
                                                  border: Border.all(
                                                    color:
                                                        theme.isDark
                                                            ? const Color(
                                                              0xffbdab82,
                                                            )
                                                            : const Color(
                                                              0xfff5f5f5,
                                                            ),
                                                    width: 0.2.w,
                                                  ),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.location_on,
                                                    color:
                                                        theme.isDark
                                                            ? const Color(
                                                              0xffbdab82,
                                                            )
                                                            : Colors.black87,
                                                    size: 5.w,
                                                  ),
                                                  onPressed: () {
                                                    AppLat =
                                                        filteredList[index]
                                                            .latitude
                                                            .toString();
                                                    AppLon =
                                                        filteredList[index]
                                                            .longitude
                                                            .toString();
                                                    selectedUserId =
                                                        filteredList[index].id
                                                            .toString();
                                                    Get.back();
                                                    moveToLocation();
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ),
                                            ),
                                            filteredList[index].tags == null ||
                                                    (filteredList[index]
                                                            .tags
                                                            ?.isEmpty ??
                                                        true)
                                                ? const SizedBox.shrink()
                                                : Container(
                                                  margin: EdgeInsets.only(
                                                    top: 8.h,
                                                  ),
                                                  height: 5.h,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    padding: EdgeInsets.only(
                                                      left: 2.w,
                                                    ),
                                                    itemCount:
                                                        businessprofileModel
                                                            ?.data?[index]
                                                            .tags
                                                            ?.length ??
                                                        0,
                                                    itemBuilder: (
                                                      context,
                                                      tagIndex,
                                                    ) {
                                                      final tag =
                                                          businessprofileModel
                                                              ?.data?[index]
                                                              .tags?[tagIndex];
                                                      print(
                                                        "tag ave che knau @${tag?.img}",
                                                      );
                                                      return Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      2.w,
                                                                  vertical:
                                                                      0.5.h,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    15,
                                                                  ),
                                                              border: Border.all(
                                                                color:
                                                                    Colors
                                                                        .grey
                                                                        .shade200,
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  height: 2.5.h,
                                                                  width: 2.5.h,
                                                                  decoration: const BoxDecoration(
                                                                    shape:
                                                                        BoxShape
                                                                            .circle,
                                                                  ),
                                                                  child: ClipOval(
                                                                    child: CachedNetworkImage(
                                                                      imageUrl:
                                                                          tag?.img ??
                                                                          "",
                                                                      height:
                                                                          3.h,
                                                                      width:
                                                                          3.h,
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                      placeholder:
                                                                          (
                                                                            context,
                                                                            url,
                                                                          ) => const CircularProgressIndicator(
                                                                            color:
                                                                                AppColors.maincolor,
                                                                          ),
                                                                      errorWidget:
                                                                          (
                                                                            context,
                                                                            url,
                                                                            error,
                                                                          ) => Image.asset(
                                                                            'assets/images/waveeLogoShort.png',
                                                                            height:
                                                                                3.h,
                                                                            width:
                                                                                3.h,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 1.w,
                                                                ),
                                                                Text(
                                                                  tag?.name ??
                                                                      "No Tags",
                                                                  style: TextStyle(
                                                                    color:
                                                                        theme.isDark
                                                                            ? AppColors.white
                                                                            : AppColors.black,
                                                                    fontSize:
                                                                        16.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        AppConstants
                                                                            .manrope,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(width: 2.w),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                            if (index != 0)
                                              Divider(
                                                thickness: 1,
                                                color: Colors.grey.shade300,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  Widget _filterButtons(
    String text,
    IconData icon,
    VoidCallback onTap,
    Color iconColor,
    Color textColor,
  ) {
    final theme = Provider.of<ThemeController>(context, listen: false);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
            color:
                theme.isDark
                    ? const Color(0xff272727)
                    : const Color(0xfff5f5f5),
            border: Border.all(
              color:
                  theme.isDark
                      ? const Color(0xffbdab82)
                      : const Color(0xfff5f5f5),
              width: 0.2.w,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: theme.isDark ? const Color(0xffbdab82) : Colors.black87,
              ),
              SizedBox(width: 1.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      theme.isDark ? const Color(0xffbdab82) : Colors.black87,
                  fontFamily: AppConstants.manropeBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBottomSheet(BusnessViewModal? busnessviewmodal) async {
    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;
    final theme = Provider.of<ThemeController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgcolor,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          theme.isDark
                              ? const Color(0xff1a1a1a)
                              : AppColors.bgcolor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color:
                                theme.isDark
                                    ? const Color(0xff272727)
                                    : Colors.white70,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage:
                                            (busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.logo
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? CachedNetworkImageProvider(
                                                  busnessviewmodal!
                                                      .data!
                                                      .business!
                                                      .logo!,
                                                )
                                                : const AssetImage(
                                                      "assets/images/waveeLogoShort.png",
                                                    )
                                                    as ImageProvider,
                                      ).paddingOnly(right: 2.5.w, top: 1.h),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              busnessviewmodal
                                                      ?.data
                                                      ?.business
                                                      ?.businessName ??
                                                  "N/A",
                                              style: TextStyle(
                                                fontSize: 19.sp,
                                                color:
                                                    theme.isDark
                                                        ? const Color(
                                                          0xffbdab82,
                                                        )
                                                        : Colors.black87,
                                                // fontWeight: FontWeight.w900,
                                                fontFamily:
                                                    AppConstants.manropeBold,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              "${(busnessviewmodal?.data?.distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
                                              style: TextStyle(
                                                color:
                                                    theme.isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontSize: 15.sp,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.user
                                                            ?.address ==
                                                        null ||
                                                    busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.user
                                                            ?.address ==
                                                        0 ||
                                                    busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.user
                                                            ?.address ==
                                                        ""
                                                ? Container()
                                                : Text(
                                                  busnessviewmodal
                                                                  ?.data
                                                                  ?.business
                                                                  ?.user
                                                                  ?.address
                                                                  ?.city !=
                                                              null &&
                                                          busnessviewmodal
                                                                  ?.data
                                                                  ?.business
                                                                  ?.user
                                                                  ?.address
                                                                  ?.country !=
                                                              null
                                                      ? "${busnessviewmodal?.data?.business?.user?.address?.city}, ${busnessviewmodal?.data?.business?.user?.address?.country}"
                                                      : "N/A",
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    color:
                                                        theme.isDark
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            width: 8.w,
                                            height: 8.w,
                                            decoration: BoxDecoration(
                                              color:
                                                  theme.isDark
                                                      ? const Color(0xff272727)
                                                      : Colors.grey.shade300,
                                              border: Border.all(
                                                color:
                                                    theme.isDark
                                                        ? const Color(
                                                          0xffbdab82,
                                                        )
                                                        : Colors.white,
                                                width: 0.2.w,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.close_rounded,
                                                  color:
                                                      theme.isDark
                                                          ? const Color(
                                                            0xffbdab82,
                                                          )
                                                          : Colors.black,
                                                  size: 18.sp,
                                                ),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(left: 2.w),
                                  Container(
                                    margin: EdgeInsets.only(top: 1.5.h),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          for (
                                            int i = 0;
                                            i <
                                                (busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.tags
                                                        ?.length ??
                                                    0);
                                            i++
                                          ) ...[
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 2.w,
                                                vertical: 0.5.h,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                  color:
                                                      theme.isDark
                                                          ? const Color(
                                                            0xffbdab82,
                                                          )
                                                          : Colors.black
                                                              .withValues(
                                                                alpha: .2,
                                                              ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    height: 2.h,
                                                    width: 2.h,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape: BoxShape.circle,
                                                        ),
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            busnessviewmodal
                                                                ?.data
                                                                ?.business
                                                                ?.tags?[i]
                                                                .img ??
                                                            "",
                                                        height: 3.h,
                                                        width: 3.h,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        1,
                                                                  ),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => const Image(
                                                              image: AssetImage(
                                                                "assets/images/waveeLogoShort.png",
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  Text(
                                                    busnessviewmodal
                                                            ?.data
                                                            ?.business
                                                            ?.tags?[i]
                                                            .name ??
                                                        "No Tags",
                                                    style: TextStyle(
                                                      color:
                                                          theme.isDark
                                                              ? const Color(
                                                                0xffbdab82,
                                                              )
                                                              : Colors.black87,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily:
                                                          AppConstants.manrope,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 2.w),
                                          ],
                                        ],
                                      ).paddingOnly(left: 2.w, bottom: 1.h),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).paddingOnly(bottom: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Container(
                              //   margin: EdgeInsets.only(left: 2.w),
                              //   child: GestureDetector(
                              //     onTap: () async {
                              //       if (busnessviewmodal?.data?.business?.id !=
                              //           null) {
                              //         await handleLikeTap();
                              //       } else {}
                              //     },
                              //     child: Container(
                              //       height: 4.5.h,
                              //       width: 27.w,
                              //       padding: EdgeInsets.symmetric(
                              //         horizontal: 5,
                              //         vertical: 5,
                              //       ),
                              //       decoration: BoxDecoration(
                              //         color: Colors.grey.shade300,
                              //         borderRadius: BorderRadius.circular(20),
                              //       ),
                              //       child: Row(
                              //         mainAxisAlignment:
                              //         MainAxisAlignment.center,
                              //         children: [
                              //           Icon(
                              //             busnessviewmodal?.data?.isLiked ==
                              //                 true
                              //                 ? Icons.favorite
                              //                 : Icons.favorite_outline,
                              //             color:
                              //             busnessviewmodal?.data?.isLiked ==
                              //                 true
                              //                 ? Colors.red
                              //                 : Colors.black,
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              Container(
                                margin: EdgeInsets.only(left: 2.w),
                                child: GestureDetector(
                                  onTap: () async {
                                    await _handleLikeTap(setState);
                                  },
                                  child: Container(
                                    height: 4.5.h,
                                    width: 27.w,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.isDark
                                              ? const Color(0xff272727)
                                              : Colors.grey.shade300,
                                      border: Border.all(
                                        color:
                                            theme.isDark
                                                ? const Color(0xffbdab82)
                                                : const Color(0xfff5f5f5),
                                        width: 0.2.w,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          busnessviewmodal?.data?.isLiked ==
                                                  true
                                              ? Icons.favorite
                                              : Icons.favorite_outline,
                                          color:
                                              busnessviewmodal?.data?.isLiked ==
                                                      true
                                                  ? Colors.red
                                                  : theme.isDark
                                                  ? const Color(0xffbdab82)
                                                  : Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 4.5.h,
                                  width: 27.w,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.isDark
                                            ? const Color(0xff272727)
                                            : Colors.grey.shade300,
                                    border: Border.all(
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : const Color(0xfff5f5f5),
                                      width: 0.2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.location_on,
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : Colors.black87,
                                      size: 6.w,
                                    ),
                                    onPressed: () {
                                      if (busnessviewmodal?.data?.business !=
                                          null) {
                                        AppLat =
                                            busnessviewmodal!
                                                .data!
                                                .business!
                                                .latitude
                                                .toString();
                                        AppLon =
                                            busnessviewmodal
                                                .data!
                                                .business!
                                                .longitude
                                                .toString();
                                        selectedUserId =
                                            busnessviewmodal.data!.business!.id
                                                .toString();

                                        Get.back();
                                        moveToLocation();
                                      } else {}
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 4.5.h,
                                  width: 27.w,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.isDark
                                            ? const Color(0xff272727)
                                            : Colors.grey.shade300,
                                    border: Border.all(
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : const Color(0xfff5f5f5),
                                      width: 0.2.w,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      CupertinoIcons.chat_bubble_text,
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : Colors.black87,
                                      size: 5.w,
                                    ),
                                    onPressed: () {
                                      print(
                                        'Hello Id ${busnessviewmodal?.data?.business?.user?.id}',
                                      );
                                      print(
                                        'Mine Id ${loginModel?.data?.user?.id}',
                                      );
                                      print(
                                        'Image is ${busnessviewmodal?.data?.business?.logo}',
                                      );
                                      Get.to(
                                        MessageScreen(
                                          type: "business",
                                          businessID:
                                              busnessviewmodal
                                                  ?.data
                                                  ?.business
                                                  ?.id
                                                  .toString() ??
                                              "",

                                          chatName:
                                              busnessviewmodal
                                                  ?.data
                                                  ?.business
                                                  ?.businessName ??
                                              "N/A",
                                          conciergeID:
                                              (busnessviewmodal
                                                      ?.data
                                                      ?.business
                                                      ?.user
                                                      ?.id)
                                                  .toString(),
                                          image:
                                              busnessviewmodal
                                                  ?.data
                                                  ?.business
                                                  ?.logo ??
                                              "",
                                          chatStatus:
                                              busnessviewmodal
                                                  ?.data
                                                  ?.business
                                                  ?.chatStatus,
                                          lat: AppLat,
                                          long: AppLon,
                                        ),
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          if ((busnessviewmodal?.data?.posts ?? [])
                                  .isNotEmpty ||
                              (busnessviewmodal?.data?.events ?? [])
                                  .isNotEmpty ||
                              (busnessviewmodal?.data?.offerPromotions ?? [])
                                  .isNotEmpty ||
                              (busnessviewmodal?.data?.services ?? [])
                                  .isNotEmpty ||
                              (busnessviewmodal?.data?.products ?? [])
                                  .isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((busnessviewmodal?.data?.posts ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(height: 1.h),
                                  buildMediaListView(
                                    busnessviewmodal?.data?.posts ?? [],
                                  ),
                                ],
                                if ((busnessviewmodal?.data?.events ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "Events",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color:
                                            theme.isDark
                                                ? const Color(0xffbdab82)
                                                : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manropeBold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  buildEventListView(),
                                ],
                                if ((busnessviewmodal?.data?.offerPromotions ??
                                        [])
                                    .isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "Offers & Promotions",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color:
                                            theme.isDark
                                                ? const Color(0xffbdab82)
                                                : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manropeBold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  buildListView(
                                    busnessviewmodal?.data?.offerPromotions
                                            ?.map((e) => e.files ?? "")
                                            .toList() ??
                                        [],
                                    busnessviewmodal?.data?.offerPromotions
                                            ?.map((e) => e.url ?? "")
                                            .toList() ??
                                        [],
                                    busnessviewmodal?.data?.offerPromotions
                                            ?.map((e) => e.title ?? "No Title")
                                            .toList() ??
                                        [],
                                  ),
                                ],
                                if ((busnessviewmodal?.data?.services ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "Services",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color:
                                            theme.isDark
                                                ? const Color(0xffbdab82)
                                                : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manropeBold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  buildServiceListView(
                                    busnessviewmodal?.data?.services ?? [],
                                  ),
                                ],
                                // if ((busnessviewmodal?.data?.products ?? [])
                                //     .isNotEmpty) ...[
                                //   SizedBox(height: 2.h),
                                //   Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 8.0,
                                //     ),
                                //     child: Text(
                                //       "Products",
                                //       style: TextStyle(
                                //         fontSize: 16.sp,
                                //         fontWeight: FontWeight.bold,
                                //         fontFamily: AppConstants.manropeBold,
                                //       ),
                                //     ),
                                //   ),
                                //   SizedBox(height: 1.h),
                                //   buildViewShopTile(
                                //     icon: Icons.store,
                                //     title: "View Shop",
                                //     subtitle:
                                //         (busnessviewmodal
                                //                         ?.data
                                //                         ?.business
                                //                         ?.loyaltyInfo ==
                                //                     null ||
                                //                 busnessviewmodal
                                //                         ?.data
                                //                         ?.business
                                //                         ?.loyaltyInfo
                                //                         ?.loyaltyOrderThreshold ==
                                //                     null ||
                                //                 busnessviewmodal
                                //                         ?.data
                                //                         ?.business
                                //                         ?.loyaltyInfo
                                //                         ?.loyaltyOrderThreshold ==
                                //                     0)
                                //             ? "Order 5 times to get 20% discount behind the scenes"
                                //             : "You're getting closer to an exclusive reward! Complete "
                                //                 "${busnessviewmodal?.data?.business?.loyaltyInfo?.ordersCompletedWithBusiness} "
                                //                 "more orders to unlock a ${busnessviewmodal?.data?.business?.loyaltyInfo?.loyaltyDiscountPercentage?.replaceAll(RegExp(r'\\.0+\$'), '')}% discount on your next purchase.",
                                //     onTap: () {
                                //       Get.to(
                                //         BusinessDetailPage(
                                //           businessID:
                                //               busnessviewmodal
                                //                   ?.data
                                //                   ?.business
                                //                   ?.id
                                //                   .toString() ??
                                //               "",
                                //           userID:
                                //               loginModel?.data?.user?.id
                                //                   .toString() ??
                                //               "",
                                //           long: AppLon,
                                //           lat: AppLat,
                                //         ),
                                //       );
                                //     },
                                //   ),
                                // ],
                                if ((busnessviewmodal?.data?.products ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "Products",
                                      style: TextStyle(
                                        color:
                                            theme.isDark
                                                ? const Color(0xffbdab82)
                                                : Colors.black87,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manropeBold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  buildViewShopTile(
                                    icon: Icons.store,
                                    title: "View Shop",
                                    subtitle:
                                        _isBusinessClosedToday()
                                            ? "Shop is closed today"
                                            : (busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.loyaltyInfo ==
                                                    null ||
                                                busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.loyaltyInfo
                                                        ?.loyaltyOrderThreshold ==
                                                    null ||
                                                busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.loyaltyInfo
                                                        ?.loyaltyOrderThreshold ==
                                                    0)
                                            ? "Order 5 times to get 20% discount behind the scenes"
                                            : "You're getting closer to an exclusive reward! Complete "
                                                "${busnessviewmodal?.data?.business?.loyaltyInfo?.ordersCompletedWithBusiness} "
                                                "more orders to unlock a ${busnessviewmodal?.data?.business?.loyaltyInfo?.loyaltyDiscountPercentage?.replaceAll(RegExp(r'\\.0+\$'), '')}% discount on your next purchase.",
                                    onTap: () {
                                      _isBusinessClosedToday()
                                          ? null
                                          : Get.to(
                                            BusinessDetailPage(
                                              businessID:
                                                  busnessviewmodal
                                                      ?.data
                                                      ?.business
                                                      ?.id
                                                      .toString() ??
                                                  "",
                                              userID:
                                                  loginModel?.data?.user?.id
                                                      .toString() ??
                                                  "",
                                              long: AppLon,
                                              lat: AppLat,
                                            ),
                                          );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          SizedBox(height: 2.h),
                          Container(
                            width: 110.w,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  theme.isDark
                                      ? const Color(0xff272727)
                                      : const Color(0xfff5f5f5),
                              border: Border.all(
                                color:
                                    theme.isDark
                                        ? const Color(0xffbdab82)
                                        : const Color(0xFFE5E5E5),
                                width: 0.2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final address =
                                        busnessviewmodal
                                            ?.data
                                            ?.business
                                            ?.user
                                            ?.address;
                                    if (address != null &&
                                        address.address != null &&
                                        address.city != null &&
                                        address.country != null &&
                                        address.address!.isNotEmpty &&
                                        address.city!.isNotEmpty &&
                                        address.country!.isNotEmpty) {
                                      final fullAddress =
                                          "${address.address}, ${address.city}, ${address.country}";
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (BuildContext context) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  theme.isDark
                                                      ? const Color(0xff1a1a1a)
                                                      : Colors.white,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 3,
                                                  margin: const EdgeInsets.only(
                                                    top: 12,
                                                    bottom: 20,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.isDark
                                                            ? Colors.black
                                                            : const Color(
                                                              0xfff5f5f5,
                                                            ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                      ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Get There",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            theme.isDark
                                                                ? const Color(
                                                                  0xffbdab82,
                                                                )
                                                                : Colors
                                                                    .black87,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 0.5.h),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        theme.isDark
                                                            ? const Color(
                                                              0xff272727,
                                                            )
                                                            : const Color(
                                                              0xfff5f5f5,
                                                            ),

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.05,
                                                            ),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Platform.isIOS
                                                          ? Container(
                                                            child: ListTile(
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical: 6,
                                                                  ),
                                                              leading: SizedBox(
                                                                width: 32,
                                                                height: 30,
                                                                child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        6,
                                                                      ),
                                                                  child: Image.asset(
                                                                    'assets/images/applemap.jpg',
                                                                    width: 32,
                                                                    height: 32,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                    errorBuilder: (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) {
                                                                      return Container(
                                                                        width:
                                                                            32,
                                                                        height:
                                                                            32,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.blue,
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                6,
                                                                              ),
                                                                        ),
                                                                        child: const Icon(
                                                                          Icons
                                                                              .map,
                                                                          color: Color(
                                                                            0xffbdab82,
                                                                          ),
                                                                          size:
                                                                              18,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              title: Text(
                                                                "Open in Apple Maps",
                                                                style: TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      theme.isDark
                                                                          ? const Color(
                                                                            0xffbdab82,
                                                                          )
                                                                          : Colors
                                                                              .black87,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                ),
                                                              ),
                                                              trailing: Icon(
                                                                Icons
                                                                    .chevron_right,
                                                                color:
                                                                    Colors
                                                                        .grey[400],
                                                                size: 20,
                                                              ),
                                                              onTap: () {
                                                                Get.back();
                                                                final query =
                                                                    Uri.encodeComponent(
                                                                      fullAddress,
                                                                    );
                                                                final appleMapsUrl =
                                                                    Uri.parse(
                                                                      "https://maps.apple.com/?q=$query",
                                                                    );
                                                                launchUrl(
                                                                  appleMapsUrl,
                                                                  mode:
                                                                      LaunchMode
                                                                          .externalApplication,
                                                                );
                                                              },
                                                            ),
                                                          )
                                                          : const SizedBox(),
                                                      Container(
                                                        height: 0.5,
                                                        color: Colors.grey[300],
                                                      ),
                                                      Container(
                                                        child: ListTile(
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 6,
                                                              ),
                                                          leading: SizedBox(
                                                            width: 32,
                                                            height: 30,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                              child: Image.asset(
                                                                'assets/images/gogglemap.jpg',
                                                                width: 32,
                                                                height: 32,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                errorBuilder: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Container(
                                                                    width: 32,
                                                                    height: 32,
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            6,
                                                                          ),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .location_on,
                                                                      color:
                                                                          theme.isDark
                                                                              ? const Color(
                                                                                0xffbdab82,
                                                                              )
                                                                              : Colors.black87,
                                                                      size: 18,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            "Open in Google Maps",
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  theme.isDark
                                                                      ? const Color(
                                                                        0xffbdab82,
                                                                      )
                                                                      : Colors
                                                                          .black87,
                                                              fontFamily:
                                                                  AppConstants
                                                                      .manrope,
                                                            ),
                                                          ),
                                                          trailing: Icon(
                                                            Icons.chevron_right,
                                                            color:
                                                                theme.isDark
                                                                    ? const Color(
                                                                      0xffbdab82,
                                                                    )
                                                                    : Colors
                                                                        .black87,
                                                            size: 20,
                                                          ),
                                                          onTap: () {
                                                            Get.back();
                                                            final query =
                                                                Uri.encodeComponent(
                                                                  fullAddress,
                                                                );
                                                            final googleMapsUrl =
                                                                Uri.parse(
                                                                  "https://www.google.com/maps/search/?api=1&query=$query",
                                                                );
                                                            launchUrl(
                                                              googleMapsUrl,
                                                              mode:
                                                                  LaunchMode
                                                                      .externalApplication,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 0.5,
                                                        color: Colors.grey[300],
                                                      ),
                                                      Container(
                                                        child: ListTile(
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 6,
                                                              ),
                                                          leading: SizedBox(
                                                            width: 32,
                                                            height: 30,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                              child: Image.asset(
                                                                'assets/images/copyimage.jpg',
                                                                width: 32,
                                                                height: 32,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                errorBuilder: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Container(
                                                                    width: 32,
                                                                    height: 32,
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          theme.isDark
                                                                              ? const Color(
                                                                                0xff272727,
                                                                              )
                                                                              : const Color(
                                                                                0xfff5f5f5,
                                                                              ),
                                                                      border: Border.all(
                                                                        color: const Color(
                                                                          0xffbdab82,
                                                                        ),
                                                                        width:
                                                                            0.2.w,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            6,
                                                                          ),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .content_copy,
                                                                      color:
                                                                          theme.isDark
                                                                              ? const Color(
                                                                                0xffbdab82,
                                                                              )
                                                                              : Colors.black87,
                                                                      size: 18,
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          title: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Copy Address",
                                                                style: TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      theme.isDark
                                                                          ? const Color(
                                                                            0xffbdab82,
                                                                          )
                                                                          : Colors
                                                                              .black87,
                                                                  fontFamily:
                                                                      AppConstants
                                                                          .manrope,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 2,
                                                              ),
                                                              Text(
                                                                fullAddress,
                                                                style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                          onTap: () {
                                                            Clipboard.setData(
                                                              ClipboardData(
                                                                text:
                                                                    fullAddress,
                                                              ),
                                                            );
                                                            Get.back();

                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: const Text(
                                                                  "Address copied to clipboard",
                                                                ),
                                                                duration:
                                                                    const Duration(
                                                                      seconds:
                                                                          2,
                                                                    ),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                margin: EdgeInsets.only(
                                                                  bottom:
                                                                      MediaQuery.of(
                                                                        context,
                                                                      ).size.height -
                                                                      150,
                                                                  left: 20,
                                                                  right: 20,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 0.5.h),
                                                Container(
                                                  width: double.infinity,
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          theme.isDark
                                                              ? const Color(
                                                                0xff272727,
                                                              )
                                                              : const Color(
                                                                0xfff5f5f5,
                                                              ),
                                                      foregroundColor:
                                                          Colors.black,
                                                      elevation: 0,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        side: BorderSide(
                                                          color:
                                                              Colors.grey[300]!,
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Done",
                                                      style: TextStyle(
                                                        color:
                                                            theme.isDark
                                                                ? const Color(
                                                                  0xffbdab82,
                                                                )
                                                                : Colors
                                                                    .black87,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 1.h),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: buildListTile(
                                    context: context,
                                    icon: Icons.location_on,
                                    title: "Address",
                                    subtitle:
                                        (busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.user
                                                        ?.address
                                                        ?.address ==
                                                    null ||
                                                busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.user
                                                        ?.address
                                                        ?.address ==
                                                    "" ||
                                                busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.user
                                                        ?.address
                                                        ?.city ==
                                                    null ||
                                                busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.user
                                                        ?.address
                                                        ?.city ==
                                                    "" ||
                                                busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.user
                                                        ?.address
                                                        ?.country ==
                                                    null ||
                                                busnessviewmodal
                                                        ?.data
                                                        ?.business
                                                        ?.user
                                                        ?.address
                                                        ?.country ==
                                                    "")
                                            ? "N/A"
                                            : "${busnessviewmodal?.data?.business?.user?.address?.address}, "
                                                "${busnessviewmodal?.data?.business?.user?.address?.city}, "
                                                "${busnessviewmodal?.data?.business?.user?.address?.country}",
                                  ),
                                ),
                                Divider(color: Colors.grey.shade300),
                                InkWell(
                                  onTap: () {
                                    final phone =
                                        busnessviewmodal
                                            ?.data
                                            ?.business
                                            ?.user
                                            ?.mobileNo;
                                    if (phone != null &&
                                        phone.toString().isNotEmpty) {
                                      final telUrl = Uri.parse(
                                        "tel:0${phone.toString()}",
                                      );
                                      launchUrl(
                                        telUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: buildListTile(
                                    icon: Icons.phone,
                                    title: "Phone",
                                    context: context,
                                    subtitle:
                                        busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.user
                                                    ?.mobileNo ==
                                                null
                                            ? "N/A"
                                            : "0${(busnessviewmodal?.data?.business?.user?.mobileNo).toString()}",
                                  ),
                                ),
                                Divider(color: Colors.grey.shade300),
                                ExpansionTile(
                                  leading: Icon(
                                    Icons.access_time,
                                    color:
                                        theme.isDark
                                            ? Colors.grey
                                            : Colors.black87,
                                  ),
                                  title: Text(
                                    "Opening Hours",
                                    style: TextStyle(
                                      color:
                                          theme.isDark
                                              ? const Color(0xffbdab82)
                                              : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppConstants.manropeBold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _getCurrentDayStatus(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontFamily: AppConstants.manropeBold,
                                    ),
                                  ),
                                  shape: const Border(),
                                  collapsedShape: const Border(),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        children: [
                                          _buildHoursRow(
                                            "Monday",
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.openingHours
                                                ?.monday,
                                          ),
                                          _buildHoursRow(
                                            "Tuesday",
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.openingHours
                                                ?.tuesday,
                                          ),
                                          _buildHoursRow(
                                            "Wednesday",
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.openingHours
                                                ?.wednesday,
                                          ),
                                          _buildHoursRow(
                                            "Thursday",
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.openingHours
                                                ?.thursday,
                                          ),
                                          _buildHoursRow(
                                            "Friday",
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.openingHours
                                                ?.friday,
                                          ),
                                          _buildHoursRow(
                                            "Saturday",
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.openingHours
                                                ?.saturday,
                                          ),
                                          _buildHoursRow(
                                            "Sunday",
                                            busnessviewmodal
                                                ?.data
                                                ?.business
                                                ?.openingHours
                                                ?.sunday,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: Colors.grey.shade300),
                                InkWell(
                                  onTap: () {
                                    final website =
                                        busnessviewmodal
                                            ?.data
                                            ?.business
                                            ?.website;
                                    if (website != null && website.isNotEmpty) {
                                      String url = website;
                                      if (!url.startsWith('http://') &&
                                          !url.startsWith('https://')) {
                                        url = 'https://$url';
                                      }
                                      final websiteUrl = Uri.parse(url);
                                      launchUrl(
                                        websiteUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: buildListTile(
                                    icon: Icons.language,
                                    title: "Website",
                                    context: context,
                                    subtitle:
                                        busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.website
                                                    ?.isNotEmpty ==
                                                true
                                            ? busnessviewmodal!
                                                .data!
                                                .business!
                                                .website!
                                            : "N/A",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "You May Also Like",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.isDark
                                      ? const Color(0xffbdab82)
                                      : Colors.black87,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Column(
                            children: [
                              for (
                                int i = 0;
                                i <
                                        (busnessviewmodal
                                                ?.data
                                                ?.nearbyBusinesses
                                                ?.length ??
                                            0) &&
                                    i < 5;
                                i++
                              ) ...[
                                InkWell(
                                  onTap: () {
                                    Get.back();
                                    print(
                                      "Business Chceck ID: ${busnessviewmodal?.data?.nearbyBusinesses?[i].id}",
                                    );
                                    BussinessViewProfile(
                                      (busnessviewmodal
                                              ?.data
                                              ?.nearbyBusinesses?[i]
                                              .id)
                                          .toString(),
                                    );
                                  },
                                  child: Container(
                                    width: 110.w,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.isDark
                                              ? const Color(0xff272727)
                                              : const Color(0xfff5f5f5),
                                      border: Border.all(
                                        color:
                                            theme.isDark
                                                ? const Color(0xffbdab82)
                                                : const Color(0xfff5f5f5),
                                        width: 0.2.w,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 2,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            print(
                                              "Business ID: ${busnessviewmodal?.data?.nearbyBusinesses?[i].id}",
                                            );
                                            BussinessViewProfile(
                                              (busnessviewmodal
                                                      ?.data
                                                      ?.nearbyBusinesses?[i]
                                                      .id)
                                                  .toString(),
                                            );
                                          },
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                              busnessviewmodal
                                                      ?.data
                                                      ?.nearbyBusinesses?[i]
                                                      .logo ??
                                                  "https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png",
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                busnessviewmodal
                                                            ?.data
                                                            ?.nearbyBusinesses?[i]
                                                            .businessName
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? busnessviewmodal!
                                                        .data!
                                                        .nearbyBusinesses![i]
                                                        .businessName!
                                                    : "N/A",
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  color:
                                                      theme.isDark
                                                          ? const Color(
                                                            0xffbdab82,
                                                          )
                                                          : Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ReadMoreText(
                                                  busnessviewmodal
                                                              ?.data
                                                              ?.nearbyBusinesses?[i]
                                                              .description
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? busnessviewmodal!
                                                          .data!
                                                          .nearbyBusinesses![i]
                                                          .description!
                                                      : "N/A",
                                                  trimLines: 3,
                                                  colorClickableText:
                                                      Colors.blue,
                                                  trimMode: TrimMode.Line,
                                                  trimCollapsedText:
                                                      ' Show more',
                                                  trimExpandedText:
                                                      ' Show less',
                                                  moreStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    letterSpacing: 1,
                                                    color: AppColors.maincolor,
                                                  ),
                                                  lessStyle: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1,
                                                    color: AppColors.maincolor,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Distance : ",
                                                      style: TextStyle(
                                                        color:
                                                            theme.isDark
                                                                ? const Color(
                                                                  0xffbdab82,
                                                                )
                                                                : Colors
                                                                    .black87,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          (busnessviewmodal
                                                                      ?.data
                                                                      ?.nearbyBusinesses?[i]
                                                                      .distance !=
                                                                  null)
                                                              ? "${busnessviewmodal!.data!.nearbyBusinesses![i].distance!.toStringAsFixed(2)} Miles"
                                                              : "N/A",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14.sp,
                                                        fontFamily:
                                                            AppConstants
                                                                .manrope,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  Future<void> BussinessProfile() async {
    bool internet = await checkInternet();
    if (!internet) {
      buildErrorDialog(context, 'Error', "Internet Required");
      return;
    }
    try {
      setState(() {
        isMapLoading = true;
        isLoading = true;
      });

      DateTime startTime = DateTime.now();

      final apiFuture = CommunityProvider().businessProfileApi(
        (loginModel?.data?.user?.id).toString(),
        AppLat,
        AppLon,
      );
      DateTime markerStartTime = DateTime.now();
      final markerFuture = _loadMarkers();

      final response = await apiFuture;

      DateTime apiEndTime = DateTime.now();
      Duration apiDuration = apiEndTime.difference(startTime);

      if (response.statusCode == 200) {
        businessprofileModel = BusinessProfileModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
      } else {
        buildErrorDialog(context, 'Error', "Something went wrong.");
      }

      await markerFuture;
      DateTime markerEndTime = DateTime.now();
      Duration markerDuration = markerEndTime.difference(markerStartTime);

      DateTime endTime = DateTime.now();
      Duration totalTime = endTime.difference(startTime);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isMapLoading = false;
        });
      }
    }
  }

  BussinessViewProfile(String id) {
    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().businessProfileViewApi(id, AppLat, AppLon).then((
          response,
        ) async {
          busnessviewmodal = BusnessViewModal.fromJson(response.data);
          if (response.statusCode == 200) {
            setState(() {
              isSending = false;
            });

            await _showBottomSheet(busnessviewmodal);
          } else if (response.statusCode == 422) {
            setState(() {
              isSending = false;
            });
          } else {
            setState(() {
              isSending = false;
            });
          }
        });
      } else {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  handleLikeTap1() {
    bool isCurrentlyLiked = busnessviewmodal?.data?.isLiked ?? false;
    String newLikeStatus = isCurrentlyLiked ? "0" : "1";
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (busnessviewmodal?.data?.business?.id).toString(),
      'is_like': newLikeStatus,
    };

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .businessLikeApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                bussinesslikemodel = BussinessLikeModel.fromJson(response.data);

                setState(() {
                  isSending = true;
                });

                request.clear();
                final String businessId =
                    (busnessviewmodal?.data?.business?.id).toString();
                Get.back();
                await Future.delayed(const Duration(milliseconds: 100));
                BussinessViewProfile(businessId);
              } else if (response.statusCode == 429) {
                setState(() {
                  isSending = true;
                });
              } else {
                print(
                  "Internal Server Error - Status Code: ${response.statusCode}",
                );

                EasyLoading.showError("Internal Server Error");
              }
            })
            .catchError((error, stackTrace) {});
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  Future<void> _handleLikeTap(StateSetter setState) async {
    if (busnessviewmodal?.data?.business?.id == null) return;

    // Immediate UI update
    setState(() {
      bool currentLikeStatus = busnessviewmodal?.data?.isLiked ?? false;
      busnessviewmodal?.data?.isLiked = !currentLikeStatus;
    });

    // API call
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (busnessviewmodal?.data?.business?.id).toString(),
      'is_like': (busnessviewmodal?.data?.isLiked == true) ? "1" : "0",
    };

    try {
      final response = await CommunityProvider().businessLikeApi(data);

      if (response.statusCode != 200) {
        // If API fails, revert the UI state
        setState(() {
          busnessviewmodal?.data?.isLiked =
              !(busnessviewmodal?.data?.isLiked ?? false);
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update like status"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // If API call fails, revert the UI state
      setState(() {
        busnessviewmodal?.data?.isLiked =
            !(busnessviewmodal?.data?.isLiked ?? false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveLikeStatus(String businessId, bool isLiked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedBusinesses = prefs.getStringList('likedBusinesses') ?? [];

    if (isLiked) {
      if (!likedBusinesses.contains(businessId)) {
        likedBusinesses.add(businessId);
      }
    } else {
      likedBusinesses.remove(businessId);
    }

    await prefs.setStringList('likedBusinesses', likedBusinesses);
  }

  Future<bool> getLikeStatus(String businessId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedBusinesses = prefs.getStringList('likedBusinesses') ?? [];
    return likedBusinesses.contains(businessId);
  }

  businesssearchapi() {
    final Map<String, String> data = {"business_name": search.text.toString()};

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().searchBusinessApi(data).then((response) async {
          busnesssearchModal = BusnessSearchModal.fromJson(response.data);
          if (response.statusCode == 200) {
            setState(() {
              businessprofileModel = businessprofileModel;
            });

            setState(() {
              isLoading = false;
            });
          } else if (response.statusCode == 422) {
            setState(() {
              isLoading = false;
            });
          } else {
            isLoading = false;
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  getlikeapi() {
    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityProvider().getLikeBusinessApi(
            (loginModel?.data?.user?.id).toString(),
            AppLat,
            AppLon,
          );
          setState(() {
            isSending = false;
          });

          if (response.statusCode == 200) {
            getlikeModal = GetLikeModal.fromJson(response.data);
            _showFavouriteBottomSheet();
          } else {
            _showFavouriteBottomSheet();
          }
        } catch (e) {
          setState(() {
            isSending = false;
          });

          _showFavouriteBottomSheet();
        }
      } else {
        setState(() {
          isSending = false;
        });

        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  getvisitedapi() {
    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityProvider().getVisitorApi(
            (loginModel?.data?.user?.id).toString(),
            AppLat,
            AppLon,
          );
          setState(() {
            isSending = false;
          });

          if (response.statusCode == 200) {
            getvisitedModal = GetVisitedModal.fromJson(response.data);
          }
          _showvisitedBottomSheet();
        } catch (e) {
          setState(() {
            isSending = false;
          });

          _showvisitedBottomSheet();
        }
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  unlikeBusiness(int index) {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (getlikeModal?.data?[index].businessId).toString(),
      'is_like': "0",
    };

    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .businessLikeApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                setState(() {
                  getlikeModal?.data?.removeAt(index);
                });

                setState(() {
                  isSending = false;
                });

                Get.back();

                await Future.delayed(const Duration(milliseconds: 500));
                _showFavouriteBottomSheet();
              } else {
                setState(() {
                  isSending = false;
                });
              }
            })
            .catchError((error) {
              setState(() {
                isSending = false;
              });
            });
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  categorieslistapi() {
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityProvider().getCategoryApi();
          EasyLoading.dismiss();
          if (response.statusCode == 200) {
            categoriesModel = CategoriesModel.fromJson(response.data);
          }
        } catch (e) {
          EasyLoading.dismiss();
        }
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  void CategoriesProfileView(
    String id,
    String categoryName,
    String categoryImage,
  ) {
    setState(() {
      isSending = true;
    });

    checkInternet().then((internet) async {
      if (!internet) {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
        return;
      }

      try {
        final response = await CommunityProvider().categoryViewApi(
          (loginModel?.data?.user?.id).toString(),
          AppLon,
          AppLat,
          id,
        );

        if (response.statusCode == 200) {
          viewcategoriesmodel = ViewCategoriesModel.fromJson(response.data);
          setState(() {
            isSending = false;
          });

          await _showcategoriesdBottomSheet(
            viewcategoriesmodel,
            categoryName,
            categoryImage,
          );
        } else if (response.statusCode == 422) {
          setState(() {
            isSending = false;
          });
        } else if (response.statusCode == 429) {
          setState(() {
            isSending = false;
          });
          buildErrorDialog(
            context,
            'Too Many Requests',
            'You are making requests too quickly. Please wait a moment and try again.',
          );
        } else {
          setState(() {
            isSending = false;
          });
          buildErrorDialog(
            context,
            'Error',
            'Something went wrong (${response.statusCode})',
          );
        }
      } catch (e) {
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
      }
    });
  }

  OfferPromoAsViewedApi() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'offerPromotion_id':
          (busnessviewmodal?.data?.offerPromotions?[0].id).toString(),
    };

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().markOfferPromoApi(data).then((response) async {
          if (response.statusCode == 200) {
            offerpromoAsviewedmodel = OfferPromoAsViewedModel.fromJson(
              response.data,
            );
          } else if (response.statusCode == 429) {
          } else {}
        });
      } else {
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  sendlistap(selectedid) {
    final Map<String, String> data = {};
    data['user_id'] = loginModel?.data?.user?.id.toString() ?? "";
    data['event_id'] = selectedid ?? "";

    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider()
            .sendeventapi(data)
            .then((response) async {
              sendeventModel = SendeventModel.fromJson(response.data);

              if (response.statusCode == 200 || sendeventModel?.data == 200) {
              } else if (response.statusCode == 422) {
                load = false;
              } else {
                EasyLoading.showError("Internal Server Error");
              }

              setState(() {
                isLoading = false;
              });
              return false;
            })
            .catchError((error) {
              setState(() {
                isLoading = false;
              });
              EasyLoading.showError("Request Failed");
              return false;
            });
      } else {
        setState(() {
          isLoading = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
        return false;
      }
    });
  }

  Widget buildListView(
    List<String?> items,
    List<String?> links,
    List<String?> titles,
  ) {
    if (busnessviewmodal?.data?.offerPromotions == null ||
        busnessviewmodal!.data!.offerPromotions!.isEmpty) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(items.length, (index) {
          String? linkUrl = links[index]?.trim();

          String displayUrl = '';
          if (linkUrl != null && linkUrl.isNotEmpty) {
            try {
              Uri uri = Uri.parse(linkUrl);
              displayUrl = uri.host;

              if (displayUrl.length > 30) {
                displayUrl = '${displayUrl.substring(0, 27)}...';
              }
            } catch (e) {
              displayUrl = linkUrl;
              if (displayUrl.length > 30) {
                displayUrl = '${displayUrl.substring(0, 27)}...';
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () async {
                  OfferPromoAsViewedApi();
                  if (linkUrl != null && linkUrl.isNotEmpty) {
                    Uri uri = Uri.parse(linkUrl);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {}
                  } else {}
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: items[index] ?? '',
                      placeholder:
                          (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => const Image(
                            image: AssetImage(
                              "assets/images/waveeLogoShort.png",
                            ),
                          ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  titles[index] ?? "No Title",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(Icons.link, size: 16.sp, color: Colors.blue),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        displayUrl.isNotEmpty
                            ? displayUrl
                            : "No link available",
                        style: TextStyle(
                          fontFamily: AppConstants.manrope,
                          fontSize: 14.sp,
                          color: Colors.blue,
                          decoration:
                              linkUrl != null && linkUrl.isNotEmpty
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildMediaListView(List<Posts> mediaItems) {
    return SizedBox(
      height: 35.h,
      child: InViewNotifierList(
        scrollDirection: Axis.horizontal,
        isInViewPortCondition: (deltaTop, deltaBottom, viewPortDimension) {
          return deltaTop < (0.5 * viewPortDimension) &&
              deltaBottom > (0.5 * viewPortDimension);
        },
        itemCount: mediaItems.length,
        builder: (context, index) {
          final item = mediaItems[index];
          return InViewNotifierWidget(
            id: '$index',
            builder: (context, isInView, _) {
              return Container(
                width: 44.w,
                height: 30.h,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        () => FullScreenMediaView(
                          postId: item.id ?? 0,
                          posts:
                              mediaItems
                                  .map(
                                    (e) => {
                                      'id': e.id,
                                      'type': e.type,
                                      'file': e.file,
                                    },
                                  )
                                  .toList(),
                          initialIndex: index, // 👈 Add this new field
                        ),
                      );
                    },

                    child:
                        item.file == null || item.file!.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : CachedNetworkImage(
                              imageUrl: item.file!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Image(
                                    image: AssetImage(
                                      "assets/images/Applogo_remove_background.png",
                                    ),
                                  ),
                            ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildServiceListView(List<Services> services) {
    if (busnessviewmodal?.data?.services == null ||
        busnessviewmodal!.data!.services!.isEmpty) {
      return const Center();
    }
    final theme = Provider.of<ThemeController>(context, listen: false);

    // Get today’s weekday name (like Monday, Tuesday, etc.)
    String todayWeekday = DateFormat('EEEE').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(services.length, (index) {
          String imageUrl = services[index].images ?? '';
          String? availabilityStr = services[index].availability;

          // Split comma-separated days
          List<String> availableDays = [];
          if (availabilityStr != null && availabilityStr.isNotEmpty) {
            availableDays =
                availabilityStr
                    .split(',')
                    .map((e) => e.trim().toLowerCase())
                    .toList();
          }

          // Check if today's day exists in the list
          bool isAvailableToday = availableDays.contains(
            todayWeekday.toLowerCase(),
          );

          return Opacity(
            opacity: isAvailableToday ? 1.0 : 0.5, // dim unavailable
            child: IgnorePointer(
              ignoring: !isAvailableToday, // disable tap if unavailable
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3.0,
                  vertical: 4.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          theme.isDark
                              ? const Color(0xffbdab82)
                              : Colors.grey.shade300,
                      width: 0.2.w,
                    ),
                    color:
                        theme.isDark
                            ? const Color(0xff272727)
                            : const Color(0xfff5f5f5),

                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    onTap: () {
                      print(
                        "Service ID: ${services[index].id}, Business ID: ${busnessviewmodal?.data?.business?.id}",
                      );
                      _isBusinessClosedToday()
                          ? null
                          : Get.to(
                            () => ServiceDetailsPage(
                              serviceID: services[index].id.toString(),
                              businessID:
                                  busnessviewmodal?.data?.business?.id
                                      .toString() ??
                                  "",
                            ),
                          );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 15.w,
                      height: 7.h,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl:
                              imageUrl.isNotEmpty
                                  ? imageUrl
                                  : 'https://portal.wavee.ai/public/business/img/logos/waveeLogoShort.png',
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget:
                              (context, url, error) => Icon(
                                Icons.home_repair_service,
                                color: Colors.grey,
                                size: 8.w,
                              ),
                        ),
                      ),
                    ),
                    title: Text(
                      services[index].title ?? "Service Name",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            theme.isDark
                                ? const Color(0xffbdab82)
                                : Colors.black,
                        fontFamily: AppConstants.manrope,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            Expanded(
                              child:
                                  services[index].offerPrice != null
                                      ? Row(
                                        children: [
                                          // Original price with line-through
                                          Text(
                                            "£${services[index].price ?? 'N/A'}",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontFamily: AppConstants.manrope,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(width: 2.w),
                                          // Offer price
                                          Text(
                                            "£${services[index].offerPrice}",
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.green[700],
                                              fontFamily: AppConstants.manrope,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      )
                                      : Text(
                                        "£${services[index].price ?? 'N/A'}",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: Colors.green[700],
                                          fontFamily: AppConstants.manrope,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.event_available,
                              color:
                                  isAvailableToday ? Colors.blue : Colors.grey,
                              size: 16.sp,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _isBusinessClosedToday()
                                    ? "Shop is closed"
                                    : "Availability: ${services[index].availability ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      isAvailableToday
                                          ? Colors.blue[700]
                                          : Colors.grey,
                                  fontFamily: AppConstants.manrope,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                          theme.isDark
                              ? const Color(0xffbdab82)
                              : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildEventListView() {
    if (busnessviewmodal?.data?.events == null ||
        busnessviewmodal!.data!.events!.isEmpty) {
      return const Center();
    }
    final theme = Provider.of<ThemeController>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(busnessviewmodal!.data!.events!.length, (index) {
          String eventId =
              busnessviewmodal?.data?.events?[index].id?.toString() ?? "";

          bool isRequestSent = sentEventIds.contains(eventId);
          bool isLoading = false;

          return StatefulBuilder(
            builder: (context, setState) {
              void showRequestDialog() {
                if (busnessviewmodal?.data?.events?[index].requestEvent
                        ?.toLowerCase() ==
                    "pending") {
                  return;
                }

                requestController.clear();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Dialog(
                          backgroundColor:
                              theme.isDark
                                  ? const Color(0xff1a1a1a)
                                  : AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  theme.isDark
                                      ? const Color(0xff1a1a1a)
                                      : const Color(0xfff5f5f5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Text(
                                            "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} "
                                            "${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
                                            style: TextStyle(
                                              color:
                                                  theme.isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                              fontSize: 18.sp,
                                              fontFamily: AppConstants.manrope,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      const Align(
                                        alignment: Alignment.topRight,
                                        child: CloseButton(),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    busnessviewmodal
                                            ?.data
                                            ?.events?[index]
                                            .title ??
                                        "N/A",
                                    style: TextStyle(
                                      fontFamily: AppConstants.manrope,
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    busnessviewmodal
                                                ?.data
                                                ?.events?[index]
                                                .eventDate !=
                                            null
                                        ? DateFormat.jm().format(
                                          DateTime.parse(
                                            busnessviewmodal!
                                                .data!
                                                .events![index]
                                                .eventDate!,
                                          ),
                                        )
                                        : "N/A",
                                    style: const TextStyle(
                                      fontFamily: AppConstants.manrope,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: requestController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "Enter your request...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.black26,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.black26,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "Please enter your request";
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      batan(
                                        title: "Send Request",
                                        route: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setDialogState(() {
                                              isLoading = true;
                                            });
                                            setState(() {
                                              busnessviewmodal!
                                                  .data!
                                                  .events![index]
                                                  .requestEvent = "pending";
                                            });
                                            await sendlistap(eventId);
                                            setDialogState(() {
                                              isLoading = false;
                                            });
                                            Get.back();
                                          }
                                        },
                                        radius: 4.0.w,
                                        color: AppColors.maincolor,
                                        fontcolor: AppColors.white,
                                        height: 5.h,
                                        width: 72.w,
                                        fontsize: 17.sp,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3.0,
                  vertical: 4.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        theme.isDark
                            ? const Color(0xff272727)
                            : const Color(0xfff5f5f5),
                    border: Border.all(
                      color:
                          theme.isDark
                              ? const Color(0xffbdab82)
                              : Colors.grey.shade300,
                      width: 0.2.w,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    onTap: () {
                      // showRequestDialog();
                      print("event id Aa rahi hai $eventId");
                      Get.to(
                        EventDetail(
                          eventID: eventId,
                          status:
                              busnessviewmodal
                                  ?.data
                                  ?.events?[index]
                                  .requestEvent ??
                              "",
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 15.w,
                      height: 7.h,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child:
                            busnessviewmodal?.data?.events?[index].attachment !=
                                    null
                                ? CachedNetworkImage(
                                  imageUrl:
                                      busnessviewmodal!
                                          .data!
                                          .events![index]
                                          .attachment!,
                                  placeholder:
                                      (context, url) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Image.asset(
                                        "assets/images/waveeLogoShort.png",
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  "assets/images/waveeLogoShort.png",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                      ),
                    ),
                    title: Text(
                      busnessviewmodal?.data?.events?[index].title ??
                          "No Title",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color:
                            theme.isDark
                                ? const Color(0xffbdab82)
                                : Colors.black,
                        // color: Color(0xff272727),
                        // border: Border.all(
                        //   color: Color(0xffbdab82),
                        //   width: 0.2.w,
                        // ),
                        fontWeight: FontWeight.w500,
                        fontFamily: AppConstants.manrope,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color:
                                  theme.isDark
                                      ? const Color(0xffbdab82)
                                      : Colors.black87,
                              size: 16.sp,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                busnessviewmodal
                                        ?.data
                                        ?.events?[index]
                                        .location ??
                                    'No Location',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                  fontFamily: AppConstants.manrope,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color:
                                  theme.isDark
                                      ? const Color(0xffbdab82)
                                      : Colors.black87,
                              size: 16.sp,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (String? eventDate) {
                                  if (eventDate == null || eventDate.isEmpty) {
                                    return "N/A";
                                  }
                                  DateTime parsedDate = DateTime.parse(
                                    eventDate,
                                  );
                                  return DateFormat(
                                    'yyyy-MM-dd hh:mm a',
                                  ).format(parsedDate);
                                }(
                                  busnessviewmodal
                                          ?.data
                                          ?.events?[index]
                                          .eventDate ??
                                      "",
                                ),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                  fontFamily: AppConstants.manrope,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.blue,
                            )
                            : InkWell(
                              onTap: () {
                                showRequestDialog();
                              },
                              child:
                                  busnessviewmodal
                                              ?.data
                                              ?.events?[index]
                                              .requestEvent
                                              ?.toLowerCase() ==
                                          "pending"
                                      ? const Text(
                                        "Requested",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Color(0xffbdab82),
                                      ),
                            ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget buildProductList(List<Products> products) {
    if (busnessviewmodal?.data?.products == null ||
        busnessviewmodal!.data!.products!.isEmpty) {
      return const Center();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(products.length, (index) {
          final product = products[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () {
                  Get.to(
                    () => ProductDetailPage(
                      productID: product.id.toString() ?? "",
                      type: "product",
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      (product.image != null && product.image!.isNotEmpty)
                          ? CachedNetworkImage(
                            imageUrl: product.image!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Image.asset(
                                  'assets/images/waveeLogoShort.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                          )
                          : Image.asset(
                            'assets/images/waveeLogoShort.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                ),
                title: Text(
                  product.name ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (product.offerPrice != null)
                          Text(
                            "£${product.offerPrice}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontFamily: AppConstants.manrope,
                            ),
                          ),
                        if (product.offerPrice != null)
                          const SizedBox(width: 6),
                        Text(
                          "£${product.price}",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color:
                                product.offerPrice != null
                                    ? Colors.grey
                                    : Colors.black,
                            decoration:
                                product.offerPrice != null
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  bool _isBusinessClosedToday() {
    final now = DateTime.now();
    final today = _getDayName(now.weekday);
    final todayHours = _getHoursForDay(today);

    if (todayHours == null) return true;

    if (todayHours.closed == true) return true;

    if (todayHours.open != null && todayHours.close != null) {
      try {
        DateTime parseTime(String time) {
          // format: 11:23 AM or 6:45 PM
          final parts = time.split(" ");
          final hourMin = parts[0].split(":");

          int hour = int.parse(hourMin[0]);
          int minute = int.parse(hourMin[1]);
          final ampm = parts[1].toUpperCase();

          if (ampm == "PM" && hour != 12) hour += 12;
          if (ampm == "AM" && hour == 12) hour = 0;

          return DateTime(now.year, now.month, now.day, hour, minute);
        }

        final openTime = parseTime(todayHours.open);
        final closeTime = parseTime(todayHours.close);

        if (now.isBefore(openTime) || now.isAfter(closeTime)) {
          return true;
        }

        return false;
      } catch (e) {
        return true;
      }
    }

    return true;
  }

  bool _isBusinessOpenToday() {
    final today = _getDayName(DateTime.now().weekday);
    final todayHours = _getHoursForDay(today);
    if (todayHours == null) return false;
    if (todayHours.closed == true) return false;
    if (todayHours.open != null && todayHours.close != null) {
      return true;
    }
    return false;
  }

  String _getCurrentDayStatus() {
    final now = DateTime.now();
    final today = _getDayName(now.weekday);
    final todayHours = _getHoursForDay(today);

    if (todayHours == null) {
      return "Not Set Yet";
    }

    if (todayHours.closed == true) {
      return "Closed Today";
    }

    if (todayHours.open != null && todayHours.close != null) {
      return "${todayHours.open} - ${todayHours.close}";
    }

    return "Hours not available";
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "Monday";
    }
  }

  dynamic _getHoursForDay(String day) {
    final openingHours = busnessviewmodal?.data?.business?.openingHours;
    if (openingHours == null) return null;

    switch (day.toLowerCase()) {
      case "monday":
        return openingHours.monday;
      case "tuesday":
        return openingHours.tuesday;
      case "wednesday":
        return openingHours.wednesday;
      case "thursday":
        return openingHours.thursday;
      case "friday":
        return openingHours.friday;
      case "saturday":
        return openingHours.saturday;
      case "sunday":
        return openingHours.sunday;
      default:
        return null;
    }
  }

  Widget _buildHoursRow(String day, dynamic dayHours) {
    final isToday = day == _getDayName(DateTime.now().weekday);
    final theme = Provider.of<ThemeController>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration:
          isToday
              ? BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              )
              : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isToday ? 8 : 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              day,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color:
                    isToday
                        ? Colors.blue
                        : theme.isDark
                        ? const Color(0xffbdab82)
                        : Colors.black87,
              ),
            ),
            Text(
              _getHoursText(dayHours),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color:
                    isToday
                        ? Colors.blue
                        : theme.isDark
                        ? const Color(0xffbdab82)
                        : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHoursText(dynamic dayHours) {
    if (dayHours == null) return "N/A";
    if (dayHours.closed == true) return "Closed";
    if (dayHours.open != null && dayHours.close != null) {
      return "${dayHours.open} - ${dayHours.close}";
    }
    return "N/A";
  }

  Widget buildViewShopTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Provider.of<ThemeController>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.5.w, vertical: 1.2.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.2.h),
          decoration: BoxDecoration(
            color:
                theme.isDark
                    ? const Color(0xff272727)
                    : const Color(0xfff5f5f5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  theme.isDark
                      ? const Color(0xffbdab82)
                      : const Color(0xFFE5E5E5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26,
                color: theme.isDark ? const Color(0xffbdab82) : Colors.black87,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppConstants.manrope,

                        color:
                            theme.isDark
                                ? const Color(0xffbdab82)
                                : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: AppConstants.manrope,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.isDark ? const Color(0xffbdab82) : Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildListTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required BuildContext context,
}) {
  final theme = Provider.of<ThemeController>(context, listen: false);

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 25,
          color: theme.isDark ? const Color(0xffbdab82) : Colors.black87,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color:
                      theme.isDark ? const Color(0xffbdab82) : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppConstants.manropeBold,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.isDark ? const Color(0xffbdab82) : Colors.black87,
        ),
      ],
    ),
  );
}
