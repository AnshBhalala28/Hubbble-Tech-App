import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

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
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavee/Screen/Community%20Screen/Community%20Screen/Model/BusnessViewModal.dart';
import 'package:wavee/Screen/HomeNewPage/View/homenewpage.dart';
import 'package:wavee/Screen/Message_screen/View/messageScreen.dart';
import 'package:wavee/Screen/Product%20Detail%20Page/view/product_detail_page.dart';
import 'package:wavee/Screen/ViewProfile/Model/profile_model.dart';
import 'package:wavee/Screen/ViewProfile/Provider/profile_provider.dart';
import 'package:wavee/comman/colors.dart';

import '../../../../comman/bottom_bar.dart';
import '../../../../comman/check_inernet_connecty.dart';
import '../../../../comman/const.dart';
import '../../../../comman/custom_batan.dart';
import '../../../../comman/error_dialog.dart';
import '../../../../comman/loader.dart';
import '../../../../comman/videowidget.dart';
import '../../../Event/Model/send_event_model.dart';
import '../../../Event/Provider/event_provider.dart';
import '../../../Service Detail Page/View/service_detail_page.dart';
import '../../../ViewProfile/View/viewprofile.dart';
import '../Model/BusinessSearchModal.dart';
import '../Model/CategoriesModel.dart';
import '../Model/GetLikeModal.dart';
import '../Model/GetVisitedModal.dart';
import '../Model/OfferPromoAsViewedModel.dart';
import '../Model/RequestModal.dart';
import '../Model/ViewCategoriesModel.dart';
import '../Model/businesslikemodel.dart';
import '../Model/businessprofilemodel.dart';
import '../Provider/community_provider.dart';
import 'FullScreenImageView.dart';
import 'StoryView.dart';

class CommunityScreen extends StatefulWidget {
  int? selected;

  CommunityScreen({super.key, this.selected});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
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

  bool _isBottomSheetOpen = false; // Track BottomSheet state
  Map<String, List<Data1>> locationGroups =
      {}; // ✅ Global variable for tracking locations
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
      isMapLoading = true; // Map loader
    });

    _mapStyle = '''[
    {
      "featureType": "poi",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "poi.business",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "poi.attraction",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "featureType": "poi.place_of_worship",
      "elementType": "all",
      "stylers": [
        { "visibility": "off" }
      ]
    }
  ]''';

    _getCurrentLocation();
    GetProfile();
    checkLikeStatus();
    businesssearchapi();
    categorieslistapi();
  }

  void moveToLocation() {
    if (AppLat.isNotEmpty && AppLon.isNotEmpty) {
      double latitude = double.tryParse(AppLat) ?? 0.0;
      double longitude = double.tryParse(AppLon) ?? 0.0;

      if (latitude != 0.0 && longitude != 0.0) {
        // પહેલા કેમેરા એનિમેશન કરો
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(latitude, longitude),
            20.0, // Large zoom for close-up effect
          ),
        );
        print("Moved to Location: Lat: $latitude, Lon: $longitude");

        // ખાસ કરીને પસંદ કરેલા યુઝરને દેખાડવા માટે માર્કર લોડ કરો
        _loadSelectedUserMarker();
      } else {
        print("Invalid stored location.");
      }
    } else {
      print("AppLat or AppLon is empty.");
    }
  }

  //busnessviewmodal?.data?.business?.logo
  Future<void> _loadSelectedUserMarker() async {
    if (businessprofileModel?.data == null ||
        businessprofileModel!.data!.isEmpty ||
        selectedUserId == null ||
        selectedUserId!.isEmpty) {
      setState(() => isMapLoading = false);
      return;
    }

    Data1? selectedUser = businessprofileModel!.data!.firstWhere(
      (data) => data.id.toString() == selectedUserId,
      orElse: () => Data1(),
    );

    if (selectedUser == null ||
        selectedUser.latitude == null ||
        selectedUser.longitude == null) {
      _loadMarkers();
      return;
    }

    double lat = double.parse(selectedUser.latitude!);
    double lon = double.parse(selectedUser.longitude!);

    String profileImage = _getBusinessLogoForProfile(
      selectedUser.id,
      selectedUser.logo,
    );
    // BitmapDescriptor icon = await getCustomMarker(profileImage, size: 120);

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
          // onTap: () {
          //   _showUserProfile(selectedUser);
          // },
          anchor: hasStory ? Offset(0.5, 0.8) : Offset(0.5, 0.5),

          onTap: () => _handleMarkerTap(selectedUser),
        ),
      };
      isMapLoading = false;
    });
  }

  void _showUserProfile(Data1? user) {
    if (user == null) return;

    // અહીં તમારું મૂળ BussinessViewProfile ફંક્શન કૉલ કરો
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

    // 1. પહેલું, isMapLoading = false કરીને UI અનબ્લોક કરો
    // જેથી યુઝર ઇન્ટરફેસ સાથે ઇન્ટરેક્ટ કરી શકે
    setState(() {
      isMapLoading = false;
    });

    Set<Marker> markers = {};
    Map<String, List<Data1>> locationGroups = {};

    // 2. Data ને batches માં પ્રોસેસ કરવા માટે ડેટાને પહેલા organize કરો
    for (var data in businessprofileModel!.data!) {
      if (data.latitude != null && data.longitude != null) {
        String locationKey = "${data.latitude},${data.longitude}";
        locationGroups.putIfAbsent(locationKey, () => []);
        locationGroups[locationKey]!.add(data);
      }
    }

    // 3. બેચ પ્રોસેસિંગ setup કરો
    final int batchSize = 5;
    final List<MapEntry<String, List<Data1>>> entries =
        locationGroups.entries.toList();

    // 4. પહેલો બેચ લોડ કરો
    int processedCount = 0;
    int currentBatchSize =
        (entries.length < batchSize) ? entries.length : batchSize;

    // Prepare the first batch of markers
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

      // બ્લોકિંગ કોડ પહેલા અલગથી ચલાવો
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
          );
        }),
      );

      processedCount++;
    }

    // પહેલા બેચના માર્કર પ્રદર્શિત કરો
    final firstBatchMarkers = await Future.wait(firstBatchFutures);
    setState(() {
      _markers = firstBatchMarkers.toSet();
    });

    // 5. બાકીના માર્કર્સ ટુકડે ટુકડે લોડ કરો
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
            );
          }),
        );
      }

      final batchMarkers = await Future.wait(batchFutures);
      setState(() {
        _markers.addAll(batchMarkers);
      });

      processedCount += nextBatchSize;

      // આ દરેક બેચ વચ્ચે UI ને અપડેટ થવા દો
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  void _onCameraIdle() {
    mapController.getZoomLevel().then((zoom) {
      if (zoom < 16.0) {
        //  Always reload markers when zooming out
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

    // ✅ Use first user's actual profile image (NO EXTRA STATIC IMAGE)
    final Uint8List imgBytes = await getBytesFromCanvas(profileImageUrl, size);
    final ui.Codec codec = await ui.instantiateImageCodec(
      imgBytes,
      targetWidth: size,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    canvas.drawImage(image, Offset(0, 0), paint);

    // ✅ Show `+count` icon slightly above the profile image
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

      // એક જ કસ્ટમ મારકર બનાવો જેમાં લોગો અને સ્ટોરી (જો હોય તો) બંને સાથે હોય
      BitmapDescriptor combinedIcon = await getCustomMarker(
        profileImage,
        size: profileSize,
        hasStory: hasStory,
        storyPreviewUrl: storyPreviewUrl,
        showOnlyProfile: false,
        showOnlyStory: false,
      );

      // એક જ મુખ્ય મારકર ઉમેરો (લોગો + સ્ટોરી)
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
      print("Error Loading Marker Image: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  // Future<BitmapDescriptor> getCustomMarker(String imageUrl, {int size = 100}) async {
  //   try {
  //     final Uint8List markerIcon = await getBytesFromCanvas(imageUrl, size);
  //     return BitmapDescriptor.fromBytes(markerIcon);
  //   } catch (e) {
  //     print(" Error Loading Marker Image: $e");
  //     return BitmapDescriptor.defaultMarker;
  //   }
  // }

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

    // Logo dimensions
    final double logoRadius = size / 2;

    // Story dimensions - smaller than logo
    final double storySize = size * 0.65; // Slightly larger story circle
    final double storyRadius = storySize / 2;

    // Increase spacing between the circles for better tap detection
    final double verticalSpacing =
        size * 0.15; // More space between story and logo circle

    // Calculate total canvas height with increased spacing
    final double canvasHeight =
        hasStory ? (size + storySize + verticalSpacing) : size.toDouble();
    final double canvasWidth = size.toDouble();

    // Logo is positioned at the bottom
    final Offset logoCenter = Offset(
      size / 2,
      hasStory ? (canvasHeight - logoRadius) : logoRadius,
    );

    // Story is positioned more clearly above with larger gap
    final Offset storyCenter =
        hasStory
            ? Offset(size / 2, storySize * 0.5) // If has story, position at top
            : Offset(
              size / 2,
              logoRadius,
            ); // If no story, same as logo (won't be used)

    // Draw business logo circle
    paint.color = Colors.white;
    canvas.drawCircle(logoCenter, logoRadius, paint);

    // Draw the logo image
    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
      final Uint8List imgBytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        imgBytes,
        targetWidth: size,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Create clipping path for circle
      canvas.save();
      final Path logoPath =
          Path()..addOval(
            Rect.fromCircle(center: logoCenter, radius: logoRadius - 3),
          );
      canvas.clipPath(logoPath);

      // Draw the logo image
      canvas.drawImage(
        image,
        Offset(logoCenter.dx - logoRadius, logoCenter.dy - logoRadius),
        Paint(),
      );
      canvas.restore();
    } catch (e) {
      print("Error loading logo image: $e");
    }

    // Draw story circle above logo if exists with increased spacing
    if (hasStory && storyPreviewUrl?.isNotEmpty == true) {
      // Draw story border (green circle)
      paint.color = Colors.green;
      paint.strokeWidth = 4.0; // Make border thicker
      canvas.drawCircle(storyCenter, storyRadius, paint);

      // Draw white background for story image
      paint.color = Colors.white;
      canvas.drawCircle(storyCenter, storyRadius - 3, paint);

      // Draw the story preview image
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

        // Create clipping path for story circle
        canvas.save();
        final Path storyPath =
            Path()..addOval(
              Rect.fromCircle(center: storyCenter, radius: storyRadius - 5),
            );
        canvas.clipPath(storyPath);

        // Draw story preview image
        canvas.drawImage(
          storyImage,
          Offset(
            storyCenter.dx - storyRadius + 5,
            storyCenter.dy - storyRadius + 5,
          ),
          Paint(),
        );
        canvas.restore();

        // Draw thicker and more visible triangle pointer from story to profile
        final Path trianglePath = Path();
        final double triangleHeight =
            verticalSpacing * 0.9; // Much larger triangle
        final double triangleWidth = triangleHeight * 0.9; // Wider triangle

        // Define triangle points
        trianglePath.moveTo(
          storyCenter.dx,
          storyCenter.dy + storyRadius,
        ); // Top point
        trianglePath.lineTo(
          storyCenter.dx - triangleWidth,
          storyCenter.dy + storyRadius + triangleHeight,
        ); // Left point
        trianglePath.lineTo(
          storyCenter.dx + triangleWidth,
          storyCenter.dy + storyRadius + triangleHeight,
        ); // Right point
        trianglePath.close();

        // Fill triangle with same color as story circle border
        paint.color = Colors.green;
        canvas.drawPath(trianglePath, paint);
      } catch (e) {
        print("Error loading story image: $e");
      }
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
    print("Marker tapped for user ID: ${user.id}");
    bool hasStory = user.featuredPosts?.isNotEmpty == true;
    print("hasStory status: ${hasStory}");

    if (hasStory) {
      if (_showingStory) {
        setState(() {
          marker = true;
          _showingStory = false; // ટોગલ કરો
        });
        _showUserStory(user.id);
      } else {
        setState(() {
          marker = false;
          _showingStory = true; // ટોગલ કરો
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

    // userId ને string માં કન્વર્ટ કરીને ચેક કરો
    print("Opening story for user ID: $userId");

    try {
      print("print : ${userId}");
      Get.to(StoryViewerScreen(userId: userId));
    } catch (e) {
      print("Error navigating to StoryViewerScreen: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening story: $e')));
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ચેક કરો કે લૉકેશન સર્વિસ શરૂ છે કે નહિ
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("📌 Location services are disabled.");
      setState(() {
        isLoading = false; // Loader બંધ કરો
        isMapLoading = false; // Map loader બંધ
      });
      return;
    }

    // લૉકેશન પર્મિશન ચેક કરો
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("📌 Location permission denied.");
        setState(() {
          isLoading = false; // Loader બંધ
          isMapLoading = false; // Map loader બંધ
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("📌 Location permission permanently denied.");
      setState(() {
        isLoading = false; // Loader બંધ
        isMapLoading = false; // Map loader બંધ
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    AppLat = position.latitude.toString();
    AppLon = position.longitude.toString();
    print("Latitude Check again: $AppLat, Longitude Check: $AppLon");

    setState(() {
      isLocationFetched = true; // Now we can show the map
    });

    // mapController.animateCamera(CameraUpdate.newCameraPosition(
    //   CameraPosition(
    //     target: LatLng(position.latitude, position.longitude),
    //     zoom: 14.0, // Zoom level
    //   ),
    // ));

    // // હવે કરંટ પોઝિશન મેળવો
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    //
    // // Latitude અને Longitude મૂકો
    // AppLat = position.latitude.toString();
    // AppLon = position.longitude.toString();
    //
    // print("Latitude Check : $AppLat, Longitude Check: $AppLon");
    //
    // // મૅપને અપડેટ કરો (કેન્દ્રિત કરો)
    // mapController.animateCamera(CameraUpdate.newCameraPosition(
    //   CameraPosition(
    //     target: LatLng(position.latitude, position.longitude),
    //     zoom: 14.0, // ઝૂમ લેવલ
    //   ),
    // ));

    // શહેર મેળવો (વિશેષ રીતે)
    getCityName(position.latitude, position.longitude);

    setState(() {
      isMapLoading = false; // મૅપ લોડિંગ બંધ કરો
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
        // _loadMarkers();
        setState(() {
          isLoading =
              false; // Stop loader after location and markers are fetched
        }); // City Name
        print(
          ""
          ""
          ""
          ""
          ""
          " $city",
        );
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false; // Stop loader after location and markers are fetched
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey iconKey = GlobalKey();

    return Scaffold(
      bottomNavigationBar: Bottom_bar(selected: 3),
      body: WillPopScope(
        onWillPop: () async {
          Get.offAll(
            () => HomeNewPage(
              selected: 1,
              userName: "", // Pass userName if needed
            ),
          );
          return false;
        },
        child: Stack(
          children: [
            // isLoading
            //     ? Center(child: CircularProgressIndicator())
            //     :
            isLocationFetched
                ? GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    _customInfoWindowController.googleMapController =
                        controller;

                    mapController.setMapStyle(_mapStyle);

                    print("Google Map Controller Ready!");
                    print("AppLat new check : $AppLat");
                    print("AppLon new check: $AppLon");

                    // જ્યારે મૅપ તૈયાર થાય અને લોકેશન મળે, ત્યારે મૅપને અપડેટ કરો
                    // if (!isMapLoading) {
                    //   mapController.animateCamera(CameraUpdate.newCameraPosition(
                    //     CameraPosition(
                    //       target: LatLng(
                    //         double.tryParse(AppLat) ?? 21.1929627,
                    //         double.tryParse(AppLon) ?? 72.7984162,
                    //       ),
                    //       zoom: 14.0,
                    //     ),
                    //   ));
                    // }
                  },

                  onCameraIdle: _onCameraIdle,
                  // Call `_onCameraIdle()` when zooming stops
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: false,
                  myLocationEnabled: false,
                  zoomGesturesEnabled: true,
                  mapType: MapType.normal,

                  // initialCameraPosition: CameraPosition(
                  //   target: LatLng(
                  //     double.tryParse(AppLat) ??19.0760,
                  //     double.tryParse(AppLon) ?? 72.8777,
                  //   ),
                  //   zoom: 14.0,
                  // ),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(AppLat), double.parse(AppLon)),
                    zoom: 14.0,
                  ),

                  // initialCameraPosition: CameraPosition(
                  //   // target: LatLng(
                  //   //   double.parse(AppLat.toString()),
                  //   //   double.parse(AppLon.toString()),
                  //   // ),
                  //
                  //   target: LatLng(
                  //     double.tryParse(AppLat.toString()) ?? 21.1929627,
                  //     // Default latitude
                  //     double.tryParse(AppLon.toString()) ??
                  //         72.7984162, // Default longitude
                  //   ),
                  //
                  //
                  //   // target: LatLng(
                  //   //   double.tryParse(AppLat.toString()) ?? 0.0,
                  //   //   doubl e.tryParse(AppLon.toString()) ?? 0.0,
                  //   // ),
                  //   zoom: 14.0,
                  // ),
                  markers: _markers,
                  onTap: (_) {
                    _customInfoWindowController.hideInfoWindow!();
                  },
                  onCameraMove: (position) {
                    _customInfoWindowController.onCameraMove!();
                  },
                )
                : Center(child: CircularProgressIndicator()),
            // Show loader until location is ready
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 27.h,
              width: 150,
              offset: 50,
            ),

            /// map top side
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
                                child: CircularProgressIndicator(
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
                                image: DecorationImage(
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
                  // SizedBox(
                  //   width: 20,
                  // ),
                  // GestureDetector(
                  //   onTap: () => _showSearchBottomSheet(context),
                  //   child: Container(
                  //     width: 36,
                  //     height: 36,
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       color: Colors.white,
                  //     ),
                  //     child: Icon(
                  //       Icons.search,
                  //       color: Colors.black87,
                  //       size: 25,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   width: 30,
                  // ),
                  // Container(
                  //   width: 55.w,
                  //   height: 6.h,
                  //   padding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                  //   decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.all(ui.Radius.circular(20))),
                  //   child: Row(
                  //     children: [
                  //       SizedBox(width: 2.w),
                  //       GestureDetector(
                  //         onTap: () {
                  //           Get.to(ViewProfile(
                  //             id: loginModel?.data?.user?.id,
                  //           ));
                  //         },
                  //         child: ClipOval(
                  //           child: CachedNetworkImage(
                  //             imageUrl: profileModel?.data?.user?.profile ?? '',
                  //
                  //             // : "https://imgs.search.brave.com/ul1ELzJhn3eDT8eV6L6sFVf3Ca6nEr9s5DHA1JybFYE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5zcHJvdXRzb2Np/YWwuY29tL3VwbG9h/ZHMvMjAyMi8wNi9w/cm9maWxlLXBpY3R1/cmUuanBlZw",
                  //             imageBuilder: (context, imageProvider) => Container(
                  //               width: 10.w,
                  //               height: 10.w,
                  //               decoration: BoxDecoration(
                  //                 shape: BoxShape.circle,
                  //                 image: DecorationImage(
                  //                   image: imageProvider,
                  //                   fit: BoxFit.cover,
                  //                 ),
                  //               ),
                  //             ),
                  //             placeholder: (context, url) => Container(
                  //               width: 10.w,
                  //               height: 10.w,
                  //               alignment: Alignment.center,
                  //               decoration: BoxDecoration(
                  //                 shape: BoxShape.circle,
                  //                 color: Colors.grey.shade200,
                  //               ),
                  //               child: SizedBox(
                  //                 width: 20.sp,
                  //                 height: 20.sp,
                  //                 child: CircularProgressIndicator(
                  //                   strokeWidth: 2,
                  //                   valueColor: AlwaysStoppedAnimation<Color>(
                  //                       AppColors.maincolor),
                  //                 ),
                  //               ),
                  //             ),
                  //
                  //             errorWidget: (context, url, error) => Container(
                  //               width: 10.w,
                  //               height: 10.w,
                  //               alignment: Alignment.center,
                  //               decoration: BoxDecoration(
                  //                 shape: BoxShape.circle,
                  //                 color: Colors.grey.shade200,
                  //                 image: DecorationImage(
                  //                   image: AssetImage(
                  //                     "assets/images/waveeLogoShort.png",
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(width: 10.w),
                  //       Text(
                  //         city ?? "",
                  //         style: TextStyle(
                  //             color: Colors.black,
                  //             fontSize: 16,
                  //             fontWeight: FontWeight.bold),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),

            /// map bottom side
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showSearchBottomSheet(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: Icon(
                            Icons.search,
                            color: Colors.black87,
                            size: 25,
                          ),
                        ),
                      ),

                      SizedBox(width: 1.w),

                      SizedBox(width: 1.w),
                      //fav
                      GestureDetector(
                        onTap: () {
                          getlikeapi();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          width: 33.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            // shape: BoxShape.circle,
                            borderRadius: BorderRadius.all(
                              ui.Radius.circular(20),
                            ),
                            color: Colors.grey[200],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.pink,
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 17.sp,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Favourites",
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 1.w),
                      //visited
                      GestureDetector(
                        onTap: () {
                          getvisitedapi();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          width: 29.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            // shape: BoxShape.circle,
                            borderRadius: BorderRadius.all(
                              ui.Radius.circular(20),
                            ),
                            color: Colors.grey[200],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.purpleAccent,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 17.sp,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Visited",
                                style: TextStyle(fontSize: 16.sp),
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
                                    categoriesModel?.data?[i].id.toString() ??
                                    "";
                                String categoryName =
                                    categoriesModel?.data?[i].categoryName ??
                                    "";
                                String categoryImage =
                                    categoriesModel?.data?[i].img ??
                                    ""; // Image URL fetch kari
                                print("categoryIdcategoryId : ${categoryId}");
                                print("Selected Category Name: $categoryName");

                                CategoriesProfileView(
                                  categoryId,
                                  categoryName,
                                  categoryImage,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                height: 5.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey[200],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 3.5.h,
                                      width: 3.5.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: getCategoryColor(
                                          categoriesModel
                                                  ?.data?[i]
                                                  .categoryName ??
                                              "",
                                        ),
                                      ),
                                      child: Center(
                                        child: ClipOval(
                                          child: Image.network(
                                            categoriesModel?.data?[i].img ?? "",
                                            height: 2.h,
                                            width: 2.h,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      categoriesModel?.data?[i].categoryName ??
                                          "",
                                      style: TextStyle(fontSize: 16.sp),
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
            ),

            if (isMapLoading)
              Positioned.fill(
                child: Container(
                  // color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.maincolor,
                    ),
                  ),
                ),
              ),

            isSending
                ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4), // Background overlay
                    child: Center(child: Loader()), // Centered Loader
                  ),
                )
                : SizedBox(),
            // Hide when not sending

            // showSuccessMsg ?
            //   Positioned(
            //     bottom: 140,
            //     left: 0,
            //     right: 0,
            //     child: Center(
            //       child: Container(
            //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            //         decoration: BoxDecoration(
            //           color: Colors.green,
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Text(
            //           "Like Sent Successfully!",
            //           style: TextStyle(
            //             color: Colors.black,
            //             fontSize: 14.sp,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ) :SizedBox(),
          ],
        ),
      ),
    );
  }

  void GetProfile() {
    final Map<String, String> data = {
      'id': loginModel?.data?.user?.id.toString() ?? '',
    };
    print("RegisterApi : ${data}");

    checkInternet().then((internet) async {
      if (internet) {
        ProfileProvider().ProfileApi(data).then((response) async {
          profileModel = ProfileModel.fromJson(jsonDecode(response.body));
          if (response.statusCode == 200 && profileModel?.status == 200) {
            print("adfdsfsdf${response.body}");
            print(
              "1111111111>>>>>>>>>>>>.${profileModel?.data?.user?.profile}",
            );

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            //log("Error");
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
    if (_isBottomSheetOpen) return; // Already open, don't open another

    _isBottomSheetOpen = true; // Set flag to true
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          // Start from 60% of the screen
          maxChildSize: 1.0,
          // Allow full screen dragging
          minChildSize: 0.3,
          // Minimum 30% screen
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgcolor,
                    borderRadius: BorderRadius.vertical(
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
                      SizedBox(height: 10),

                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.pink,
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Favourites",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${getlikeModal?.data?.length ?? "No"} Favourites",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 8.w, // Responsive width using Sizer
                            height: 8.w, // Responsive height to keep it square
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Light grey background
                              shape: BoxShape.circle, // Circle shape
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded, // Close icon
                                  color: Colors.black,
                                  size: 5.w, // Responsive icon size
                                ),
                                onPressed: () {
                                  Get.back(); // Close the bottom sheet
                                },
                                padding: EdgeInsets.zero,
                                // No extra padding around the icon
                                constraints:
                                    BoxConstraints(), // Prevents unnecessary expansion
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Scrollable List of Favourite Businesses
                      Expanded(
                        child:
                            (getlikeModal?.data == null ||
                                    getlikeModal!.data!.isEmpty)
                                ? Center(
                                  child: Text(
                                    "No Favourites Added!",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  // DraggableScrollableSheet support
                                  padding: EdgeInsets.zero,
                                  // Extra padding remove
                                  itemCount: getlikeModal?.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    bool isFirst =
                                        index == 0; // Check if first item
                                    bool isLast =
                                        index ==
                                        (getlikeModal?.data?.length ?? 1) -
                                            1; // Check if last item

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
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft:
                                                    isFirst
                                                        ? Radius.circular(15)
                                                        : Radius.zero,
                                                topRight:
                                                    isFirst
                                                        ? Radius.circular(15)
                                                        : Radius.zero,
                                                bottomLeft:
                                                    isLast
                                                        ? Radius.circular(15)
                                                        : Radius.zero,
                                                bottomRight:
                                                    isLast
                                                        ? Radius.circular(15)
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
                                                SizedBox(width: 15),
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
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      SizedBox(height: 3),
                                                      Text(
                                                        "${(getlikeModal?.data?[index].distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    unlikeBusiness(index);
                                                  },
                                                  // onTap: () =>
                                                  //     unlikeBusiness(index),
                                                  child: Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                    size: 28,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isLast) // Divider only if it's not the last item
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
      _isBottomSheetOpen = false; // Reset flag when sheet is closed
    });
  }

  void _showvisitedBottomSheet() async {
    if (_isBottomSheetOpen) return;

    _isBottomSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgcolor,
                    borderRadius: BorderRadius.vertical(
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
                      SizedBox(height: 10),

                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purpleAccent,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Recently Visited",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${getvisitedModal?.data?.length ?? "No"}  Recently Visited",
                                    style: TextStyle(
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
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: Colors.black,
                                  size: 5.w,
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      // Scrollable List of Favourite Businesses
                      Expanded(
                        child:
                            (getvisitedModal?.data == null ||
                                    getvisitedModal!.data!.isEmpty)
                                ? Center(
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  itemCount: getvisitedModal?.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    bool isFirst =
                                        index == 0; // Check if first item
                                    bool isLast =
                                        index ==
                                        (getvisitedModal?.data?.length ?? 1) -
                                            1; // Check if last item

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
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                topLeft:
                                                    isFirst
                                                        ? Radius.circular(15)
                                                        : Radius.zero,
                                                topRight:
                                                    isFirst
                                                        ? Radius.circular(15)
                                                        : Radius.zero,
                                                bottomLeft:
                                                    isLast
                                                        ? Radius.circular(15)
                                                        : Radius.zero,
                                                bottomRight:
                                                    isLast
                                                        ? Radius.circular(15)
                                                        : Radius.zero,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor:
                                                      Colors.grey[200],

                                                  // backgroundImage:
                                                  //     CachedNetworkImageProvider(
                                                  //   (getvisitedModal
                                                  //               ?.data?[index]
                                                  //               .business
                                                  //               ?.logo
                                                  //               ?.isEmpty ==
                                                  //           true)
                                                  //       ? "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600"
                                                  //       : getvisitedModal
                                                  //               ?.data?[index]
                                                  //               .business
                                                  //               ?.logo ??
                                                  //           "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600",
                                                  // ),
                                                  backgroundImage:
                                                      (getvisitedModal
                                                                  ?.data?[index]
                                                                  .business
                                                                  ?.logo
                                                                  ?.isEmpty ??
                                                              true)
                                                          ? AssetImage(
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
                                                SizedBox(width: 15),
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
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      SizedBox(height: 3),
                                                      Text(
                                                        // getvisitedModal
                                                        //         ?.data?[index]
                                                        //         .business
                                                        //         ?.subStatus
                                                        //         ?.capitalizeFirst ??
                                                        //     "Unknown",
                                                        "${(getvisitedModal?.data?[index].distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black54,
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
    if (_isBottomSheetOpen) return; // Already open, don't open another

    _isBottomSheetOpen = true; // Set flag to true

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgcolor,
                    borderRadius: BorderRadius.vertical(
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
                      SizedBox(height: 10),

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
                                    //  color: categoryColors[categoryName] ??
                                    //  Colors.blue, // Dynamic color set karyo
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
                                              : Icon(
                                                Icons.category_rounded,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categoryName,
                                    //categoriesModel?.data?[0].categoryName ?? "",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${viewcategoriesmodel?.data?.length ?? "No"} $categoryName",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 8.w, // Responsive width using Sizer
                            height: 8.w, // Responsive height to keep it square
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Light grey background
                              shape: BoxShape.circle, // Circle shape
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded, // Close icon
                                  color: Colors.black,
                                  size: 5.w, // Responsive icon size
                                ),
                                onPressed: () {
                                  Get.back(); // Close the bottom sheet
                                },
                                padding: EdgeInsets.zero,
                                // No extra padding around the icon
                                constraints:
                                    BoxConstraints(), // Prevents unnecessary expansion
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      // Scrollable List of Favourite Businesses
                      Expanded(
                        child:
                            (viewcategoriesmodel?.data == null ||
                                    viewcategoriesmodel!.data!.isEmpty)
                                ? Center(
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  itemCount:
                                      viewcategoriesmodel?.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    bool isFirstItem = index == 0;
                                    bool isLastItem =
                                        index ==
                                        (viewcategoriesmodel?.data?.length ??
                                                0) -
                                            1;

                                    return Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Get.back();
                                            BussinessViewProfile(
                                              (viewcategoriesmodel
                                                      ?.data?[index]
                                                      .id)
                                                  .toString(),
                                            );
                                            print(
                                              "viewcategoriesmodel?.data?[index].id${viewcategoriesmodel?.data?[index].id}",
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12),
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
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  backgroundImage:
                                                      (viewcategoriesmodel
                                                                  ?.data?[index]
                                                                  ?.logo
                                                                  ?.isEmpty ??
                                                              true)
                                                          ? const AssetImage(
                                                            "assets/images/waveeLogoShort.png",
                                                          )
                                                          : CachedNetworkImageProvider(
                                                                viewcategoriesmodel
                                                                        ?.data?[index]
                                                                        ?.logo ??
                                                                    "",
                                                              )
                                                              as ImageProvider,
                                                ),
                                                SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        viewcategoriesmodel
                                                                ?.data?[index]
                                                                .businessName ??
                                                            "N/A",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      SizedBox(height: 3),
                                                      Text(
                                                        // viewcategoriesmodel
                                                        //         ?.data?[index]
                                                        //         .subStatus ??
                                                        //     "Unknown",
                                                        "${(viewcategoriesmodel?.data?[index].distance ?? 0).toStringAsFixed(2)} Miles",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (!isLastItem) // Divider સિવાય લાસ્ટ આઈટમ માટે નહીં દેખાય
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
      _isBottomSheetOpen = false; // Reset flag when sheet is closed
    });
  }

  //search
  void _showSearchBottomSheet(BuildContext context) {
    bool isSearching = false;
    search.clear();
    List<dynamic> filteredList = List.from(
      businessprofileModel?.data ?? [],
    ); // Initially show all businesses
    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgcolor,
                    borderRadius: BorderRadius.vertical(
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
                                border: Border.all(
                                  color: Colors.black12,
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
                                    color: Colors.black87,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: AppConstants.manrope,
                                ),
                                onTap: () {
                                  setState(() {
                                    isSearching = true;
                                  });
                                },

                                // onChanged: (value) {
                                //   setState(() {
                                //     if (value.isEmpty) {
                                //       // Reset to show all businesses when search is cleared
                                //       filteredList = List.from(
                                //           businessprofileModel?.data ?? []);
                                //     } else {
                                //       // Convert search value to lowercase once
                                //       String searchText = value.toLowerCase();
                                //
                                //       // Filter businesses based on businessName, categoryName, subcategoryName, or tags
                                //       filteredList = businessprofileModel?.data
                                //               ?.where((businessData) {
                                //             // Business Name Match
                                //             String businessName =
                                //                 (businessData.businessName ??
                                //                         "")
                                //                     .toLowerCase();
                                //             double distance =
                                //             (businessData.distance
                                //                 ??
                                //                 0.0);
                                //
                                //             // Category Name Match (directly from businessData)
                                //             String categoryName = (businessData
                                //                         .category
                                //                         ?.categoryName ??
                                //                     "")
                                //                 .toLowerCase();
                                //             bool categoryMatch = categoryName
                                //                 .contains(searchText);
                                //
                                //             // Subcategory Name Match (directly from businessData)
                                //             String subCategoryName =
                                //                 (businessData.subCategory
                                //                             ?.subCategoryName ??
                                //                         "")
                                //                     .toLowerCase();
                                //             bool subCategoryMatch =
                                //                 subCategoryName
                                //                     .contains(searchText);
                                //
                                //             // Tag Name Match
                                //             bool tagMatch = businessData.tags
                                //                     ?.any((tag) =>
                                //                         tag.name
                                //                             ?.toLowerCase()
                                //                             .contains(
                                //                                 searchText) ??
                                //                         false) ??
                                //                 false;
                                //
                                //             // Return true if any of the fields matches (Business name, Category, Subcategory, or Tag)
                                //             return businessName
                                //                     .contains(searchText) ||
                                //                 categoryMatch ||
                                //                 subCategoryMatch ||
                                //                 tagMatch;
                                //           }).toList() ??
                                //           [];
                                //     }
                                //   });
                                // },
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      // Reset to show all businesses when search is cleared
                                      filteredList = List.from(
                                        businessprofileModel?.data ?? [],
                                      );
                                    } else {
                                      String searchText = value.toLowerCase();

                                      filteredList =
                                          businessprofileModel?.data?.where((
                                            businessData,
                                          ) {
                                            // Business Name
                                            String businessName =
                                                (businessData.businessName ??
                                                        "")
                                                    .toLowerCase();

                                            // Category Name
                                            String categoryName =
                                                (businessData
                                                            .category
                                                            ?.categoryName ??
                                                        "")
                                                    .toLowerCase();
                                            bool categoryMatch = categoryName
                                                .contains(searchText);

                                            // Subcategory Name
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

                                            // Tags
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

                                            // Distance (as string)
                                            String distanceString =
                                                (businessData.distance ?? 0.0)
                                                    .toStringAsFixed(
                                                      1,
                                                    ); // e.g., "3.5"
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
                          SizedBox(width: 8),

                          // CloseButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       search.clear();
                          //       isSearching = false;
                          //       filteredList = List.from(
                          //           businessprofileModel?.data ??
                          //               []); // Reset to all data
                          //     });
                          //     Navigator.pop(context); // Close the bottom sheet
                          //   },
                          // ),
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.close_rounded, // Close icon
                                  color: Colors.black,
                                  size: 5.w, // Responsive icon size
                                ),
                                onPressed: () {
                                  setState(() {
                                    search.clear();
                                    isSearching = false;
                                    filteredList = List.from(
                                      businessprofileModel?.data ?? [],
                                    );
                                  });
                                  Get.back();
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 1.h),

                      // Filter Buttons (Hide when searching)
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
                                  spacing: 6.0, // Horizontal
                                  runSpacing: 6.0, // Vertical
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
                                              ""; // Image URL fetch kari
                                          print(
                                            "categoryIdcategoryId : ${categoryId}",
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
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          // Small padding
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ), // Smaller border radius
                                            color: Colors.grey[200],
                                          ),
                                          child: FittedBox(
                                            // Auto scales text & content
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 10, // Smaller avatar
                                                  backgroundColor: Colors.blue,
                                                  backgroundImage: NetworkImage(
                                                    categoriesModel
                                                            ?.data?[i]
                                                            .img ??
                                                        "",
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  categoriesModel
                                                          ?.data?[i]
                                                          .categoryName ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.black,
                                                    fontFamily:
                                                        AppConstants.manrope,
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

                      // Business List (Show filtered or all businesses)
                      Expanded(
                        child:
                            isLoading
                                ? Center(child: CircularProgressIndicator())
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
                                      // onTap: () {
                                      //   Get.back();
                                      //   BussinessViewProfile(
                                      //       (businessprofileModel
                                      //               ?.data?[index].id)
                                      //           .toString());
                                      //   print(
                                      //       "businessprofileModel?.data?[index].id${businessprofileModel?.data?[index].id}");
                                      // },
                                      onTap: () {
                                        // Ensure the business ID from the filtered list
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

                                        // Move to the business detail page with the correct ID
                                        Get.back(); // Close the bottom sheet
                                        BussinessViewProfile(
                                          businessId,
                                        ); // Pass the correct business ID

                                        // Print statement for debugging
                                        print(
                                          "Navigating to business details with ID: $businessId",
                                        );
                                      },

                                      child: Container(
                                        padding: EdgeInsets.all(1.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
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
                                                  // intentionally blank to trigger errorWidget when empty
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

                                                // CachedNetworkImage(
                                                //   imageUrl: filteredList[
                                                //               index]
                                                //           .profile
                                                //           .toString()
                                                //           .isNotEmpty
                                                //       ? filteredList[index]
                                                //           .profile
                                                //           .toString()
                                                //       : "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=600",
                                                //   width: 40,
                                                //   height: 40,
                                                //   fit: BoxFit.cover,
                                                //   placeholder: (context,
                                                //           url) =>
                                                //       CircularProgressIndicator(),
                                                //   errorWidget: (context, url,
                                                //           error) =>
                                                //       Image.network(
                                                //           "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTdQLwDqDwd2JfzifvfBTFT8I7iKFFevcedYg&s"),
                                                // ),
                                              ),
                                              title: Text(
                                                filteredList[index]
                                                        .businessName ??
                                                    "N/A",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              subtitle: Row(
                                                children: [
                                                  // **SubStatus Text with Conditional Color**
                                                  Text(
                                                    "${(businessprofileModel?.data?[index].subStatus?.capitalizeFirst ?? "")}",
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.bold,

                                                      // color: (businessprofileModel?.data?[index].subStatus == "active")
                                                      //     ? Colors.green //
                                                      //     : (businessprofileModel?.data?[index].subStatus == "canceled")
                                                      //     ? Colors.red //
                                                      //     :(businessprofileModel?.data?[index].subStatus == "pending")
                                                      //     ? Colors.deepOrange //
                                                      //     : Colors.grey.shade600, // Default Color
                                                      color: Colors.grey,
                                                    ),
                                                  ),

                                                  SizedBox(width: 3.w),
                                                  //

                                                  // **Distance Text**
                                                  Text(
                                                    "${(filteredList[index].distance ?? 0.0).toStringAsFixed(2)} Miles",
                                                    // "${(businessprofileModel?.data?[index].distance ?? 0).toStringAsFixed(2)} Miles",
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              trailing: Container(
                                                width: 10.w,
                                                height: 10.w,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey[100],
                                                  // boxShadow: [
                                                  //   BoxShadow(
                                                  //     color: Colors.blue
                                                  //         .withOpacity(0.3),
                                                  //     blurRadius: 6,
                                                  //     spreadRadius: 1,
                                                  //   ),
                                                  // ],
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.location_on,
                                                    color: Colors.black,
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
                                                            .toString(); // Set selected user
                                                    Get.back();
                                                    moveToLocation();
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                ),
                                              ),
                                            ),
                                            filteredList[index].tags == null ||
                                                    (filteredList[index]
                                                            .tags
                                                            ?.isEmpty ??
                                                        true)
                                                //  businessprofileModel?.data?.length == null || businessprofileModel?.data?.length == 0 || businessprofileModel?.data?.length == ""
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
                                                              // color: AppColors.bgcolor,
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  height: 2.5.h,
                                                                  width: 2.5.h,
                                                                  decoration: BoxDecoration(
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
                                                                          ) => CircularProgressIndicator(
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
                                                                        AppColors
                                                                            .black,
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
      _isBottomSheetOpen = false; // Reset flag when sheet is closed
    });
  }

  Widget _filterButtons(
    String text,
    IconData icon,
    VoidCallback onTap,
    Color iconColor,
    Color textColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Background color passed when calling
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 15.sp, color: iconColor),
              // Icon color passed when calling
              SizedBox(width: 1.w),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor, // Text color passed when calling
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //show bottomsheet
  Future<void> _showBottomSheet(BusnessViewModal? busnessviewmodal) async {
    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;
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
                      color: AppColors.bgcolor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Material(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  // Existing Row (Logo + Info + Close Button)
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
                                                : AssetImage(
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
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w900,
                                                fontFamily:
                                                    AppConstants.manrope,
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              "${(busnessviewmodal?.data?.distanceToBusiness ?? 0).toStringAsFixed(2)} Miles",
                                              style: TextStyle(
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
                                              color: Colors.grey.shade300,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.close_rounded,
                                                  color: Colors.black,
                                                  size: 18.sp,
                                                ),
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(left: 2.w),

                                  // New Row for Tags (Bottom Side)
                                  Container(
                                    margin: EdgeInsets.only(top: 1.5.h),
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
                                                color: Colors.grey.shade200,
                                              ),
                                              //color: AppColors.bgcolor,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  height: 2.h,
                                                  width: 2.h,
                                                  decoration: BoxDecoration(
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
                                                          ) => Center(
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
                                                          ) => Image(
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
                                                    color: AppColors.black,
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
                                ],
                              ),
                            ),
                          ).paddingOnly(bottom: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // Aligns vertically
                            children: [
                              // Container(
                              //   height: 5.h,
                              //   width: 20.w,
                              //   padding: EdgeInsets.only(),
                              //   decoration: BoxDecoration(
                              //     color: AppColors.white,
                              //     borderRadius: BorderRadius.circular(10),
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       // busnessviewmodal?.data?.isLiked==true?Icon(Icons.favorite, color: Colors.red):Icon(Icons.favorite_outline, color: Colors.black),
                              //
                              //       GestureDetector(
                              //         onTap: () {
                              //           if (busnessviewmodal?.data?.business?.id !=
                              //               null) {
                              //             setState(() {
                              //               handleLikeTap(busnessviewmodal!
                              //                   .data!.business!.id!
                              //                   .toString());
                              //               busnessviewmodal.data?.isLiked =
                              //                   !(busnessviewmodal.data?.isLiked ??
                              //                       false);
                              //             });
                              //           } else {
                              //             print("Error: Business ID is null.");
                              //           }
                              //         },
                              //         child: Icon(
                              //           busnessviewmodal?.data?.isLiked == true
                              //               ? Icons.favorite
                              //               : Icons.favorite_outline,
                              //           color:
                              //               busnessviewmodal?.data?.isLiked == true
                              //                   ? Colors.red
                              //                   : Colors.black,
                              //         ),
                              //       ),
                              //
                              //       SizedBox(width: 4),
                              //     ],
                              //   ),
                              // ),
                              Container(
                                margin: EdgeInsets.only(left: 2.w),
                                child: GestureDetector(
                                  // onTap: () {
                                  //   if (busnessviewmodal?.data?.business?.id !=
                                  //       null) {
                                  //     setState(() {
                                  //       handleLikeTap(busnessviewmodal!
                                  //           .data!.business!.id!
                                  //           .toString());
                                  //       busnessviewmodal.data?.isLiked =
                                  //           !(busnessviewmodal.data?.isLiked ??
                                  //               false);
                                  //     });
                                  //   } else {
                                  //     print("Error: Business ID is null.");
                                  //   }
                                  // },
                                  onTap: () async {
                                    if (busnessviewmodal?.data?.business?.id !=
                                        null) {
                                      await handleLikeTap();
                                    } else {
                                      print("Error: Business ID is null.");
                                    }
                                  },
                                  child: Container(
                                    height: 4.5.h,
                                    width: 27.w,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                      // border: Border.all(
                                      //     width: 0.5, color: Colors.grey),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                    // border:
                                    //     Border.all(width: 0.5, color: Colors.grey),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.location_on,
                                      color: Colors.black,
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
                                            busnessviewmodal!
                                                .data!
                                                .business!
                                                .longitude
                                                .toString();
                                        selectedUserId =
                                            busnessviewmodal!.data!.business!.id
                                                .toString();

                                        Get.back();
                                        moveToLocation();
                                      } else {
                                        print("Error: Business data is null");
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 4.5.h,
                                  width: 27.w,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                    // border:
                                    //     Border.all(width: 0.5, color: Colors.grey),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      CupertinoIcons.chat_bubble_text,
                                      color: AppColors.black,
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
                                        ),
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
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
                                  .isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //post
                                if ((busnessviewmodal?.data?.posts ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(height: 1.h),
                                  // Add space before posts
                                  buildMediaListView(
                                    busnessviewmodal?.data?.posts ?? [],
                                  ),
                                ],

                                //event
                                if ((busnessviewmodal?.data?.events ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(height: 2.h), // Space before section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "Events",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  buildEventListView(),
                                ],

                                //offers
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
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
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

                                //services
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
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  buildServiceListView(
                                    busnessviewmodal?.data?.services ?? [],
                                  ),
                                ],
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
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppConstants.manrope,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  buildProductList(
                                    busnessviewmodal?.data?.products ?? [],
                                  ),
                                ],
                              ],
                            ),
                          SizedBox(height: 3.h),
                          Container(
                            width: 110.w,
                            // height: 20.h,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            // Adjust padding instead of fixed height
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     final address = busnessviewmodal?.data?.business?.user?.address;
                                //     if (address != null &&
                                //         address.address != null &&
                                //         address.city != null &&
                                //         address.country != null &&
                                //         address.address!.isNotEmpty &&
                                //         address.city!.isNotEmpty &&
                                //         address.country!.isNotEmpty) {
                                //       final query = Uri.encodeComponent(
                                //           "${address.address}, ${address.city}, ${address.country}");
                                //       final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
                                //       launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                                //     }
                                //   },
                                //   child: buildListTile(
                                //     icon: Icons.location_on,
                                //     title: "Address",
                                //     subtitle: (busnessviewmodal?.data?.business?.user?.address?.address == null ||
                                //         busnessviewmodal?.data?.business?.user?.address?.address == "" ||
                                //         busnessviewmodal?.data?.business?.user?.address?.city == null ||
                                //         busnessviewmodal?.data?.business?.user?.address?.city == "" ||
                                //         busnessviewmodal?.data?.business?.user?.address?.country == null ||
                                //         busnessviewmodal?.data?.business?.user?.address?.country == "")
                                //         ? "N/A"
                                //         : "${busnessviewmodal?.data?.business?.user?.address?.address}, "
                                //         "${busnessviewmodal?.data?.business?.user?.address?.city}, "
                                //         "${busnessviewmodal?.data?.business?.user?.address?.country}",
                                //   ),
                                // ),
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (BuildContext context) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Handle bar
                                                Container(
                                                  width: 40,
                                                  height: 3,
                                                  margin: EdgeInsets.only(
                                                    top: 12,
                                                    bottom: 20,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                ),

                                                // Header
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Get There",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                SizedBox(height: 0.5.h),

                                                // Options Container
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.05),
                                                        blurRadius: 10,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Platform.isIOS
                                                          ? Container(
                                                            child: ListTile(
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical: 6,
                                                                  ),
                                                              leading: Container(
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
                                                                        child: Icon(
                                                                          Icons
                                                                              .map,
                                                                          color:
                                                                              Colors.white,
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
                                                                      Colors
                                                                          .black,
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
                                                          : SizedBox(),
                                                      // Android phone ma blank/ignore
                                                      // Divider
                                                      Container(
                                                        height: 0.5,
                                                        //  margin: EdgeInsets.only(left: 64),
                                                        color: Colors.grey[300],
                                                      ),

                                                      // Open in Google Maps
                                                      Container(
                                                        child: ListTile(
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 6,
                                                              ),
                                                          leading: Container(
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
                                                                          Colors
                                                                              .white,
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
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          trailing: Icon(
                                                            Icons.chevron_right,
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

                                                      // Divider
                                                      Container(
                                                        height: 0.5,
                                                        //  margin: EdgeInsets.only(left: 64),
                                                        color: Colors.grey[300],
                                                      ),

                                                      // Copy Address
                                                      Container(
                                                        child: ListTile(
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 16,
                                                                vertical: 6,
                                                              ),
                                                          leading: Container(
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
                                                                          Colors
                                                                              .grey[200],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            6,
                                                                          ),
                                                                    ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .content_copy,
                                                                      color:
                                                                          Colors
                                                                              .grey[600],
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
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 2,
                                                              ),
                                                              Text(
                                                                fullAddress,
                                                                style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      Colors
                                                                          .grey[600],
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

                                                            // Top થી success message show કરવા માટે
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  "Address copied to clipboard",
                                                                ),
                                                                duration:
                                                                    Duration(
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

                                                // Done button
                                                Container(
                                                  width: double.infinity,
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.white,
                                                      foregroundColor:
                                                          Colors.black,
                                                      elevation: 0,
                                                      padding:
                                                          EdgeInsets.symmetric(
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
                                        "tel:${phone.toString()}",
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
                                    subtitle:
                                        busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.user
                                                    ?.mobileNo ==
                                                null
                                            ? "N/A"
                                            : (busnessviewmodal
                                                    ?.data
                                                    ?.business
                                                    ?.user
                                                    ?.mobileNo)
                                                .toString(),
                                  ),
                                ),
                                Divider(color: Colors.grey.shade300),
                                // InkWell(
                                //   onTap: () {
                                //
                                //   },
                                //   child: buildListTile(
                                //     icon: Icons.access_time,
                                //     title: "Opening Hours",
                                //     subtitle: "",
                                //   ),
                                // ),
                                ExpansionTile(
                                  // tilePadding: EdgeInsets.zero,
                                  //childrenPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                  ),
                                  title: Text(
                                    "Opening Hours",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _getCurrentDayStatus(),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  shape: Border(),
                                  // Remove default border
                                  collapsedShape: Border(),
                                  // Remove collapsed border
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
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
                                // Website Section
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
                              color: Colors.black,
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
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
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
                                            backgroundImage: NetworkImage(
                                              busnessviewmodal
                                                      ?.data
                                                      ?.nearbyBusinesses?[i]
                                                      .logo ??
                                                  "https://randomuser.me/api/portraits/men/1.jpg",
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
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
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      AppConstants.manrope,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                // width: double.infinity,
                                                // Ensure full width
                                                // padding: EdgeInsets.symmetric(
                                                //     horizontal: 2.w),
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
                                                    color: Colors.grey.shade500,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Distance :- ",
                                                      style: TextStyle(
                                                        color: Colors.black,
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
      _isBottomSheetOpen = false; // Reset flag when sheet is closed
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
      print("⏳ API call started at: $startTime");

      // API ને Markers ને એકસાથે લોડ કરવા માટે Future.wait() વાપરીશું
      final apiFuture = CommunityProvider().BussinessProfileApi(
        (loginModel?.data?.user?.id).toString(),
        AppLat,
        AppLon,
      );
      DateTime markerStartTime = DateTime.now();
      final markerFuture = _loadMarkers(); // Async Call

      // **API અને Markers ને એકસાથ Parallel ચલાવશો**
      final response = await apiFuture;

      DateTime apiEndTime = DateTime.now();
      Duration apiDuration = apiEndTime.difference(startTime);
      print("✅ API response received in: ${apiDuration.inSeconds} seconds");

      if (response.statusCode == 200) {
        businessprofileModel = BusinessProfileModel.fromJson(
          json.decode(response.body),
        );
      } else if (response.statusCode == 404) {
        print("Business profile not found (404)");
      } else {
        buildErrorDialog(context, 'Error', "Something went wrong.");
      }

      // **Markers ને લોડ થવા દો - Already Parallel Execution માં છે**
      await markerFuture;
      DateTime markerEndTime = DateTime.now();
      Duration markerDuration = markerEndTime.difference(markerStartTime);
      print("📍 Markers loaded in: ${markerDuration.inSeconds} seconds");

      DateTime endTime = DateTime.now();
      Duration totalTime = endTime.difference(startTime);
      print("⏱️ Total loading time: ${totalTime.inSeconds} seconds");
    } catch (e, stackTrace) {
      print("❌ Error fetching business profile: $e");
      print("❌ Error fetching business profile: $stackTrace");
      // buildErrorDialog(context, 'Error', "An error occurred.");
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
    // EasyLoading.show();

    setState(() {
      isSending = true; // Show Loader
    });

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .projectlistapi(
              (loginModel?.data?.user?.id).toString(),
              id,
              AppLat,
              AppLon,
            )
            .then((response) async {
              busnessviewmodal = BusnessViewModal.fromJson(
                json.decode(response.body),
              );
              if (response.statusCode == 200) {
                print("done LIst");
                //log("data ave che che ${response.body}");
                //  EasyLoading.dismiss();
                setState(() {
                  isSending = false; // Hide Loader
                });

                await _showBottomSheet(busnessviewmodal);
              } else if (response.statusCode == 422) {
                // EasyLoading.dismiss();
                setState(() {
                  isSending = false; // Hide Loader
                });
              } else {
                //EasyLoading.dismiss();
                setState(() {
                  isSending = false;
                });
              }
            });
      } else {
        // setState(() {});
        // EasyLoading.dismiss();
        setState(() {
          isSending = false;
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  handleLikeTap() {
    bool isCurrentlyLiked = busnessviewmodal?.data?.isLiked ?? false;
    String newLikeStatus = isCurrentlyLiked ? "0" : "1";
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (busnessviewmodal?.data?.business?.id).toString(),
      'is_like': newLikeStatus,
    };
    print("🟢 Request Parameter: $data");

    setState(() {
      isSending = true; // Show Loader
      //  showSuccessMsg = true;
    });

    //   EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .IsLikeApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                bussinesslikemodel = BussinessLikeModel.fromJson(
                  json.decode(response.body),
                );
                print("Done Like Message");
                print("Response: ${response.body}");

                setState(() {
                  isSending = true; // Show Loader
                  //  showSuccessMsg = false;
                });

                // EasyLoading.dismiss();
                // EasyLoading.showSuccess("Like Sent Successfully!");
                request.clear();
                final String businessId =
                    (busnessviewmodal?.data?.business?.id).toString();
                Get.back(); // પહેલા પાછળ જાઓ
                await Future.delayed(
                  Duration(milliseconds: 100),
                ); // થોડી રાહ જુઓ
                BussinessViewProfile(businessId);
              } else if (response.statusCode == 429) {
                setState(() {
                  isSending = true; // Show Loader
                  //  showSuccessMsg = false;
                });

                //  EasyLoading.dismiss();
              } else {
                print(
                  "Internal Server Error - Status Code: ${response.statusCode}",
                );
                //  EasyLoading.dismiss();
                EasyLoading.showError("Internal Server Error");
              }
            })
            .catchError((error, stackTrace) {
              // EasyLoading.dismiss();
              //           // EasyLoading.showError("Something went wrong");
              //log("Erroerwerwrwerwr");
              print(" Error in like API: $error");
              print(" Stack Trace: $stackTrace"); // 🔹 Stack Trace print
            });
      } else {
        //  EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
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
    print("Saved liked businesses: $likedBusinesses");
  }

  Future<bool> getLikeStatus(String businessId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedBusinesses = prefs.getStringList('likedBusinesses') ?? [];
    return likedBusinesses.contains(businessId);
  }

  businesssearchapi() {
    final Map<String, String> data = {"business_name": search.text.toString()};
    // data['status'] = "complete";
    // print(data);
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().BusinessSearch(data).then((response) async {
          busnesssearchModal = BusnessSearchModal.fromJson(
            json.decode(response.body),
          );
          if (response.statusCode == 200) {
            setState(() {
              businessprofileModel = businessprofileModel;
            });

            print("done Search LIst");
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
      isSending = true; // Show Loader
    });
    //  EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityProvider().GetLikeApi(
            (loginModel?.data?.user?.id).toString(),
            AppLat,
            AppLon,
          );
          setState(() {
            isSending = false; // Hide Loader
          });
          //EasyLoading.dismiss();
          if (response.statusCode == 200) {
            getlikeModal = GetLikeModal.fromJson(json.decode(response.body));
            _showFavouriteBottomSheet();
          } else {
            _showFavouriteBottomSheet();
          }
        } catch (e) {
          setState(() {
            isSending = false; // Hide Loader
          });
          //EasyLoading.dismiss();
          _showFavouriteBottomSheet();
        }
      } else {
        setState(() {
          isSending = false; // Hide Loader
        });
        // EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  getvisitedapi() {
    setState(() {
      isSending = true; // Show Loader
    });
    //EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityProvider().GetVisitedApi(
            (loginModel?.data?.user?.id).toString(),
            AppLat,
            AppLon,
          );
          setState(() {
            isSending = false; // Hide Loader
          });
          //EasyLoading.dismiss();
          if (response.statusCode == 200) {
            getvisitedModal = GetVisitedModal.fromJson(
              json.decode(response.body),
            );
          }
          _showvisitedBottomSheet();
        } catch (e) {
          setState(() {
            isSending = false; // Hide Loader
          });
          //   EasyLoading.dismiss();
          _showvisitedBottomSheet();
        }
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  requestsendapi() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (busnessviewmodal?.data?.business?.id).toString(),
      'additional_notes': request.text.toString(),
    };
    print("request parameter : $data"); // Debugging the data payload
    EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().requestapi(data).then((response) async {
          requestmodal = RequestModal.fromJson(json.decode(response.body));
          if (response.statusCode == 200) {
            print("done request message ");
            print("response ave che ${response.body}");

            EasyLoading.dismiss();
            EasyLoading.showSuccess("Request Sent Successfully!");
            request.clear();
            Get.back();
          } else if (response.statusCode == 429) {
            EasyLoading.dismiss();
          } else {
            EasyLoading.showError("Internal Server Error");
          }
        });
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  // Business unlike function
  unlikeBusiness(int index) {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'business_id': (getlikeModal?.data?[index].businessId).toString(),
      'is_like': "0", // 0 for unlike
    };

    setState(() {
      isSending = true; // Show Loader
      //  showSuccessMsg = true;
    });
    // EasyLoading.show(status: "Removing...");

    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .IsLikeApi(data)
            .then((response) async {
              if (response.statusCode == 200) {
                print("Unlike successful: ${response.body}");

                // Then remove from UI list
                setState(() {
                  getlikeModal?.data?.removeAt(index);
                });

                setState(() {
                  isSending = false; // Show Loader
                  //  showSuccessMsg = true;
                });
                // EasyLoading.dismiss();
                // EasyLoading.showSuccess("Removed from favorites!");

                Get.back();
                // Re-open the favorite bottom sheet after a short delay
                await Future.delayed(Duration(milliseconds: 500));
                _showFavouriteBottomSheet();
              } else {
                setState(() {
                  isSending = false; // Show Loader
                });
                // EasyLoading.dismiss();
                // EasyLoading.showError("Failed to remove. Try again.");
              }
            })
            .catchError((error) {
              setState(() {
                isSending = false; // Show Loader
              });
              // EasyLoading.dismiss();
              // EasyLoading.showError("Something went wrong");
              print("Error in unlike API: $error");
            });
      } else {
        EasyLoading.dismiss();
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  categorieslistapi() {
    // EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        try {
          final response = await CommunityProvider().CategoriesApi();
          EasyLoading.dismiss();
          if (response.statusCode == 200) {
            categoriesModel = CategoriesModel.fromJson(
              json.decode(response.body),
            );
            print("Get categories success : ${response.body}");
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

  CategoriesProfileView(String id, String categoryName, String categoryImage) {
    setState(() {
      isSending = true; // Show Loader
    });
    // EasyLoading.show();
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider()
            .categoriesViewApi(
              (loginModel?.data?.user?.id).toString(),
              AppLon,
              AppLat,
              id,
            )
            .then((response) async {
              viewcategoriesmodel = ViewCategoriesModel.fromJson(
                json.decode(response.body),
              );
              if (response.statusCode == 200) {
                print("Fetch categories LIst");
                print("data cat na ave che che ${response.body}");
                setState(() {
                  isSending = false; // Hide Loader
                });
                //EasyLoading.dismiss();
                await _showcategoriesdBottomSheet(
                  viewcategoriesmodel,
                  categoryName,
                  categoryImage,
                );
              } else if (response.statusCode == 422) {
                setState(() {
                  isSending = false; // Hide Loader
                });
                //EasyLoading.dismiss();
              } else {
                setState(() {
                  isSending = false; // Hide Loader
                });
                // EasyLoading.dismiss();
              }
            });
      } else {
        // setState(() {});
        // EasyLoading.dismiss();
        setState(() {
          isSending = false; // Hide Loader
        });
        buildErrorDialog(context, 'Error', "Internet Required");
      }
    });
  }

  OfferPromoAsViewedApi() {
    final Map<String, String> data = {
      'user_id': (loginModel?.data?.user?.id).toString(),
      'offerPromotion_id':
          (busnessviewmodal?.data?.offerPromotions?[0].id).toString(),
    };
    print("request offres promotion view parameter : $data");
    checkInternet().then((internet) async {
      if (internet) {
        CommunityProvider().OfferPromoAsViewed(data).then((response) async {
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            offerpromoAsviewedmodel = OfferPromoAsViewedModel.fromJson(
              responseData,
            );
            print("View done");
          } else if (response.statusCode == 429) {
            print("Too many requests");
          } else {
            print("Internal Server Error");
          }
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
    print("send event data jai che$data");

    // Show full-screen loader
    setState(() {
      isLoading = true;
    });

    checkInternet().then((internet) async {
      if (internet) {
        EventProvider()
            .sendeventapi(data)
            .then((response) async {
              sendeventModel = SendeventModel.fromJson(
                json.decode(response.body),
              );

              if (response.statusCode == 200 || sendeventModel?.data == 200) {
                print("Response body avve che che ==>> ${response.body}");
                // projectlistap();
              } else if (response.statusCode == 422) {
                load = false;
              } else {
                EasyLoading.showError("Internal Server Error");
              }

              setState(() {
                isLoading = false; // Loader Stop (Success or Error both cases)
              });
              return false; // Failed request
            })
            .catchError((error) {
              setState(() {
                isLoading = false; // Loader Stop on Error
              });
              EasyLoading.showError("Request Failed");
              return false; // Failed request due to error
            });
      } else {
        setState(() {
          isLoading = false; // Loader Stop on No Internet
        });
        buildErrorDialog(context, 'Error', "Internet Required");
        return false; // No internet connection
      }
    });
  }

  //  Offers/promotion
  Widget buildListView(
    List<String?> items,
    List<String?> links,
    List<String?> titles,
  ) {
    if (busnessviewmodal?.data?.offerPromotions == null ||
        busnessviewmodal!.data!.offerPromotions!.isEmpty) {
      // return Center(
      //   child: Container(
      //     margin: EdgeInsets.only(top: 4.h),
      //     child: Text(
      //       "No Offers/Promotions Available",
      //       style: TextStyle(
      //           fontSize: 17.sp,
      //           fontWeight: FontWeight.bold,
      //           color: Colors.grey),
      //     ),
      //   ),
      // );
    }

    // Remove SizedBox height constraint and ListView.builder scrolling
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use Column instead of ListView.builder to avoid nested scrolling
        ...List.generate(items.length, (index) {
          String? linkUrl = links[index]?.trim();
          // Format URL for display - show only domain
          String displayUrl = '';
          if (linkUrl != null && linkUrl.isNotEmpty) {
            try {
              Uri uri = Uri.parse(linkUrl);
              displayUrl = uri.host;
              // If URL is too long, truncate it
              if (displayUrl.length > 30) {
                displayUrl = displayUrl.substring(0, 27) + '...';
              }
            } catch (e) {
              displayUrl = linkUrl;
              if (displayUrl.length > 30) {
                displayUrl = displayUrl.substring(0, 27) + '...';
              }
            }
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
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
                    print("Opening URL: $linkUrl"); // Debugging

                    // Check if the URL can be launched before opening
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      print("Error: Could not launch $linkUrl");
                    }
                  } else {
                    print("Error: Invalid URL");
                  }
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: BoxDecoration(
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
                              Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => Image(
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
                    SizedBox(width: 4),
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
                trailing: Icon(
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
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      item.type == 'video'
                          ? VideoWidget(
                            videoUrl: item.file ?? '',
                            play: isInView,
                            postId: item.id ?? 0,
                          )
                          : GestureDetector(
                            onTap: () {
                              print("Image tapped: ${item.file}");
                              Get.to(
                                () => FullScreenImageView(
                                  imageUrl: item.file ?? '',
                                  postId: item.id ?? 0,
                                ),
                              );
                            },

                            child:
                                item.file == null || item.file!.isEmpty
                                    ? Center(child: CircularProgressIndicator())
                                    : CachedNetworkImage(
                                      imageUrl: item.file!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder:
                                          (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) => Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                    ),

                            // child: CachedNetworkImage(
                            //   imageUrl: item.file ?? '',
                            //   fit: BoxFit.cover,
                            //   width: double.infinity,
                            //   height: double.infinity,
                            //   placeholder: (context, url) =>
                            //       Image.asset('assets/images/girl.png',),
                            //   errorWidget: (context, url, error) =>
                            //       Image.asset('assets/images/girl.png',),
                            // ),
                            //
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
      return Center();
    }

    // Return Column instead of SizedBox to avoid nested scrolling issues
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use List.generate instead of ListView.builder to avoid nested scrolling
        ...List.generate(services.length, (index) {
          String imageUrl = services[index].images ?? ''; // Handle null case

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () {
                  // Handle service tap if needed
                  print(
                    "service Detail ID Ave che che : ${services?[index].id ?? ''}",
                  );
                  print(
                    "service Detail ID Ave che che : ${busnessviewmodal?.data?.business?.id.toString()}",
                  );
                  Get.to(
                    () => ServiceDetailsPage(
                      serviceID: services?[index].id.toString() ?? "",
                      businessID:
                          busnessviewmodal?.data?.business?.id.toString() ?? "",
                    ),
                  );
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                leading: Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 3,
                    //     spreadRadius: 1,
                    //   ),
                    // ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl:
                          imageUrl.isNotEmpty
                              ? imageUrl
                              : 'https://media.hswstatic.com/eyJidWNrZXQiOiJjb250ZW50Lmhzd3N0YXRpYy5jb20iLCJrZXkiOiJnaWZcL3BsYXlcLzBiN2Y0ZTliLWY1OWMtNDAyNC05ZjA2LWIzZGMxMjg1MGFiNy0xOTIwLTEwODAuanBnIiwiZWRpdHMiOnsicmVzaXplIjp7IndpZHRoIjo4Mjh9fX0=',
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Center(child: CircularProgressIndicator()),
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
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manrope,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Row(
                      children: [
                        // Icon(Icons.attach_money,
                        //     color: Colors.green, size: 16.sp),
                        Text(
                          "£",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Price: ${services[index].price ?? 'N/A'}",
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
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          color: Colors.blue,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Availability: ${services[index].availability ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.blue[700],
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
                trailing: Icon(
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

  // Widget buildEventListView() {
  //   if (busnessviewmodal?.data?.events == null ||
  //       busnessviewmodal!.data!.events!.isEmpty) {
  //     return Center(
  //         // child: Container(
  //         //   margin: EdgeInsets.only(top: 4.h),
  //         //   child: Text(
  //         //     "No Events Available",
  //         //     style: TextStyle(
  //         //         fontSize: 17.sp,
  //         //         fontWeight: FontWeight.bold,
  //         //         color: Colors.grey),
  //         //   ),
  //         // ),
  //         );
  //   }
  //
  //   // Return Column instead of SizedBox to avoid nested scrolling issues
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       // Use List.generate instead of ListView.builder to avoid nested scrolling
  //       ...List.generate(busnessviewmodal!.data!.events!.length, (index) {
  //         return Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
  //           child: Container(
  //             decoration: BoxDecoration(
  //               border: Border.all(color: Colors.grey.shade300),
  //               color: AppColors.white,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: ListTile(
  //               onTap: () {
  //                 // Handle event tap if needed
  //               },
  //               contentPadding:
  //                   EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               leading: Container(
  //                 width: 15.w,
  //                 height: 7.h,
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   // boxShadow: [
  //                   //   BoxShadow(
  //                   //     color: Colors.black12,
  //                   //     blurRadius: 3,
  //                   //     spreadRadius: 1,
  //                   //   ),
  //                   // ],
  //                 ),
  //                 // child: ClipRRect(
  //                 //   borderRadius: BorderRadius.circular(30),
  //                 //   child: busnessviewmodal?.data?.events?[index].attachment !=
  //                 //           null
  //                 //       ? CachedNetworkImage(
  //                 //           imageUrl: busnessviewmodal!
  //                 //               .data!.events![index].attachment!,
  //                 //           placeholder: (context, url) =>
  //                 //               Center(child: CircularProgressIndicator()),
  //                 //           errorWidget: (context, url, error) => Icon(
  //                 //             Icons.event,
  //                 //             color: Colors.grey,
  //                 //             size: 8.w,
  //                 //           ),
  //                 //           fit: BoxFit.cover,
  //                 //         )
  //                 //       : Icon(
  //                 //           Icons.event,
  //                 //           color: Colors.grey,
  //                 //           size: 8.w,
  //                 //         ),
  //                 // ),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(30),
  //                   child: busnessviewmodal?.data?.events?[index].attachment != null
  //                       ? CachedNetworkImage(
  //                     imageUrl: busnessviewmodal!.data!.events![index].attachment!,
  //                     placeholder: (context, url) => Center(
  //                       child: CircularProgressIndicator(),
  //                     ),
  //                     errorWidget: (context, url, error) => Image.asset(
  //                       "assets/images/waveeLogoShort.png",
  //                       fit: BoxFit.cover,
  //                       width: double.infinity,
  //                       height: double.infinity,
  //                     ),
  //                     fit: BoxFit.cover,
  //                   )
  //                       : Image.asset(
  //                     "assets/images/waveeLogoShort.png",
  //                     fit: BoxFit.cover,
  //                     width: double.infinity,
  //                     height: double.infinity,
  //                   ),
  //                 ),
  //
  //               ),
  //               title: Text(
  //                 busnessviewmodal?.data?.events?[index].title ?? "No Title",
  //                 style: TextStyle(
  //                     fontSize: 15.sp,
  //                     fontWeight: FontWeight.bold,
  //                     fontFamily: AppConstants.manrope),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               subtitle: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   SizedBox(height: 4),
  //                   Row(
  //                     children: [
  //                       Icon(Icons.location_on, color: Colors.red, size: 16.sp),
  //                       SizedBox(width: 4),
  //                       Expanded(
  //                         child: Text(
  //                           "${busnessviewmodal?.data?.events?[index].location ?? 'No Location'}",
  //                           style: TextStyle(
  //                               fontSize: 14.sp,
  //                               color: Colors.grey[600],
  //                               fontFamily: AppConstants.manrope),
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 4),
  //                   Row(
  //                     children: [
  //                       Icon(Icons.access_time,
  //                           color: Colors.blue, size: 16.sp),
  //                       SizedBox(width: 4),
  //                       Expanded(
  //                         child: Text(
  //                           (String? eventDate) {
  //                             if (eventDate == null || eventDate.isEmpty)
  //                               return "N/A";
  //                             DateTime parsedDate = DateTime.parse(eventDate);
  //                             return DateFormat('yyyy-MM-dd hh:mm a')
  //                                 .format(parsedDate);
  //                           }(busnessviewmodal
  //                                   ?.data?.events?[index].eventDate ??
  //                               ""),
  //                           style: TextStyle(
  //                               fontSize: 12.sp, color: Colors.grey[700]),
  //                           maxLines: 1,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //               trailing: Icon(Icons.arrow_forward_ios,
  //                   size: 16, color: Colors.black54),
  //             ),
  //           ),
  //         );
  //       }),
  //     ],
  //   );
  // }

  Widget buildEventListView() {
    if (busnessviewmodal?.data?.events == null ||
        busnessviewmodal!.data!.events!.isEmpty) {
      return Center(
        // child: Container(
        //   margin: EdgeInsets.only(top: 4.h),
        //   child: Text(
        //     "No Events Available",
        //     style: TextStyle(
        //         fontSize: 17.sp,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.grey),
        //   ),
        // ),
      );
    }

    // Return Column instead of SizedBox to avoid nested scrolling issues
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use List.generate instead of ListView.builder to avoid nested scrolling
        ...List.generate(busnessviewmodal!.data!.events!.length, (index) {
          String eventId =
              busnessviewmodal?.data?.events?[index].id?.toString() ?? "";

          bool isRequestSent = sentEventIds.contains(eventId);
          bool isLoading = false; // Local state for loader

          return StatefulBuilder(
            builder: (context, setState) {
              // Define showRequestDialog function to avoid code duplication
              void showRequestDialog() {
                if (busnessviewmodal?.data?.events?[index]?.requestEvent
                        ?.toLowerCase() ==
                    "pending") {
                  // Do nothing if already requested
                  return;
                }

                // If not requested, show dialog
                requestController.clear();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Name
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Spacer(),
                                      // SizedBox(width: 21.w,),
                                      Text(
                                        "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} ${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18.sp,
                                          fontFamily: AppConstants.manrope,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // SizedBox(width: 8.w,),
                                      CloseButton(),
                                    ],
                                  ),

                                  //  SizedBox(height: 2),
                                  //Title
                                  Text(
                                    busnessviewmodal
                                            ?.data
                                            ?.events?[index]
                                            ?.title ??
                                        "N/A",
                                    style: TextStyle(
                                      fontFamily: AppConstants.manrope,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  //time
                                  Text(
                                    busnessviewmodal
                                                ?.data
                                                ?.events?[index]
                                                ?.eventDate !=
                                            null
                                        ? DateFormat.jm().format(
                                          DateTime.parse(
                                            busnessviewmodal!
                                                .data!
                                                .events![index]!
                                                .eventDate!,
                                          ),
                                        )
                                        : "N/A",
                                    style: TextStyle(
                                      fontFamily: AppConstants.manrope,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black38,
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  TextFormField(
                                    controller: requestController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "Enter your request...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.black26,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.black26,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    style: TextStyle(color: Colors.black),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "Please enter your request";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),

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
                                              isLoading = false; // Stop loader
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
                padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    onTap: () {
                      // Now the entire card is clickable and will open the request popup
                      showRequestDialog();
                    },
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 15.w,
                      height: 7.h,
                      decoration: BoxDecoration(shape: BoxShape.circle),
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
                                      (context, url) => Center(
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
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${busnessviewmodal?.data?.events?[index].location ?? 'No Location'}",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                  fontFamily: AppConstants.manrope,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.blue,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (String? eventDate) {
                                  if (eventDate == null || eventDate.isEmpty)
                                    return "N/A";
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
                                  color: Colors.grey[700],
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
                            ? CircularProgressIndicator(color: Colors.blue)
                            : InkWell(
                              onTap: () {
                                // Keep the original functionality for the trailing icon
                                showRequestDialog();
                              },
                              child:
                                  busnessviewmodal
                                              ?.data
                                              ?.events?[index]
                                              ?.requestEvent
                                              ?.toLowerCase() ==
                                          "pending"
                                      ? Text(
                                        "Requested",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      )
                                      : Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.black54,
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

  // Widget buildEventListView() {
  //   if (busnessviewmodal?.data?.events == null ||
  //       busnessviewmodal!.data!.events!.isEmpty) {
  //     return Center(
  //       // child: Container(
  //       //   margin: EdgeInsets.only(top: 4.h),
  //       //   child: Text(
  //       //     "No Events Available",
  //       //     style: TextStyle(
  //       //         fontSize: 17.sp,
  //       //         fontWeight: FontWeight.bold,
  //       //         color: Colors.grey),
  //       //   ),
  //       // ),
  //     );
  //   }
  //
  //   // Return Column instead of SizedBox to avoid nested scrolling issues
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       // Use List.generate instead of ListView.builder to avoid nested scrolling
  //       ...List.generate(busnessviewmodal!.data!.events!.length, (index) {
  //         String eventId = busnessviewmodal?.data?.events?[index].id?.toString() ?? "";
  //         bool isRequestSent = sentEventIds.contains(eventId);
  //         bool isLoading = false; // Local state for loader
  //
  //         return StatefulBuilder(
  //             builder: (context, setState) {
  //               return Padding(
  //                 padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.grey.shade300),
  //                     color: AppColors.white,
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: ListTile(
  //                     onTap: () {
  //                       // Handle event tap if needed
  //                     },
  //                     contentPadding:
  //                     EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                     leading: Container(
  //                       width: 15.w,
  //                       height: 7.h,
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                       ),
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(30),
  //                         child: busnessviewmodal?.data?.events?[index].attachment != null
  //                             ? CachedNetworkImage(
  //                           imageUrl: busnessviewmodal!.data!.events![index].attachment!,
  //                           placeholder: (context, url) => Center(
  //                             child: CircularProgressIndicator(),
  //                           ),
  //                           errorWidget: (context, url, error) => Image.asset(
  //                             "assets/images/waveeLogoShort.png",
  //                             fit: BoxFit.cover,
  //                             width: double.infinity,
  //                             height: double.infinity,
  //                           ),
  //                           fit: BoxFit.cover,
  //                         )
  //                             : Image.asset(
  //                           "assets/images/waveeLogoShort.png",
  //                           fit: BoxFit.cover,
  //                           width: double.infinity,
  //                           height: double.infinity,
  //                         ),
  //                       ),
  //                     ),
  //                     title: Text(
  //                       busnessviewmodal?.data?.events?[index].title ?? "No Title",
  //                       style: TextStyle(
  //                           fontSize: 15.sp,
  //                           fontWeight: FontWeight.bold,
  //                           fontFamily: AppConstants.manrope),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     subtitle: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         SizedBox(height: 4),
  //                         Row(
  //                           children: [
  //                             Icon(Icons.location_on, color: Colors.red, size: 16.sp),
  //                             SizedBox(width: 4),
  //                             Expanded(
  //                               child: Text(
  //                                 "${busnessviewmodal?.data?.events?[index].location ?? 'No Location'}",
  //                                 style: TextStyle(
  //                                     fontSize: 14.sp,
  //                                     color: Colors.grey[600],
  //                                     fontFamily: AppConstants.manrope),
  //                                 maxLines: 1,
  //                                 overflow: TextOverflow.ellipsis,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         SizedBox(height: 4),
  //                         Row(
  //                           children: [
  //                             Icon(Icons.access_time,
  //                                 color: Colors.blue, size: 16.sp),
  //                             SizedBox(width: 4),
  //                             Expanded(
  //                               child: Text(
  //                                     (String? eventDate) {
  //                                   if (eventDate == null || eventDate.isEmpty)
  //                                     return "N/A";
  //                                   DateTime parsedDate = DateTime.parse(eventDate);
  //                                   return DateFormat('yyyy-MM-dd hh:mm a')
  //                                       .format(parsedDate);
  //                                 }(busnessviewmodal
  //                                     ?.data?.events?[index].eventDate ??
  //                                     ""),
  //                                 style: TextStyle(
  //                                     fontSize: 12.sp, color: Colors.grey[700]),
  //                                 maxLines: 1,
  //                                 overflow: TextOverflow.ellipsis,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     trailing: isLoading
  //                         ? CircularProgressIndicator(color: Colors.blue)
  //                         : InkWell(
  //                       onTap: () {
  //                         if (busnessviewmodal?.data?.events?[index]?.requestEvent?.toLowerCase() == "pending") {
  //                           // Do nothing if already requested
  //                           return;
  //                         }
  //
  //                         // If not requested, show dialog
  //                         requestController.clear();
  //                         showDialog(
  //                           context: context,
  //                           builder: (BuildContext context) {
  //                             return StatefulBuilder(
  //                               builder: (context, setDialogState) {
  //                                 return Dialog(
  //                                   backgroundColor: Colors.white,
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(16),
  //                                   ),
  //                                   child: Container(
  //                                     padding: EdgeInsets.all(20),
  //                                     decoration: BoxDecoration(
  //                                       color: Colors.white,
  //                                       borderRadius: BorderRadius.circular(16),
  //                                     ),
  //                                     child: Form(
  //                                       key: _formKey,
  //                                       autovalidateMode: AutovalidateMode.onUserInteraction,
  //                                       child: Column(
  //                                         mainAxisSize: MainAxisSize.min,
  //                                         children: [
  //                                           // Name
  //                                           Text(
  //                                             "${profileModel?.data?.user?.name?.firstName.toString().capitalizeFirst ?? ""} ${profileModel?.data?.user?.name?.lastName.toString().capitalizeFirst ?? ""}",
  //                                             style: TextStyle(
  //                                               color: Colors.black,
  //                                               fontSize: 20.sp,
  //                                               fontFamily: AppConstants.manrope,
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                           ),
  //                                           SizedBox(height: 8),
  //                                           //Title
  //                                           Text(
  //                                             busnessviewmodal?.data?.events?[index]?.title ?? "N/A",
  //                                             style: TextStyle(
  //                                               fontFamily: AppConstants.manrope,
  //                                               fontSize: 16,
  //                                               fontWeight: FontWeight.bold,
  //                                               color: Colors.black38,
  //                                             ),
  //                                           ),
  //                                           SizedBox(height: 10),
  //                                           //time
  //                                           Text(
  //                                             busnessviewmodal?.data?.events?[index]?.eventDate != null
  //                                                 ? DateFormat.jm().format(DateTime.parse(busnessviewmodal!.data!.events![index]!.eventDate!))
  //                                                 : "N/A",
  //                                             style: TextStyle(
  //                                               fontFamily: AppConstants.manrope,
  //                                               fontSize: 16,
  //                                               fontWeight: FontWeight.bold,
  //                                               color: Colors.black38,
  //                                             ),
  //                                           ),
  //                                           SizedBox(height: 12),
  //
  //                                           TextFormField(
  //                                             controller: requestController,
  //                                             maxLines: 3,
  //                                             decoration: InputDecoration(
  //                                               hintText: "Enter your request...",
  //                                               border: OutlineInputBorder(
  //                                                 borderRadius: BorderRadius.circular(10),
  //                                                 borderSide: BorderSide(color: Colors.black26),
  //                                               ),
  //                                               enabledBorder: OutlineInputBorder(
  //                                                 borderRadius: BorderRadius.circular(10),
  //                                                 borderSide: BorderSide(color: Colors.black26),
  //                                               ),
  //                                               focusedBorder: OutlineInputBorder(
  //                                                 borderRadius: BorderRadius.circular(10),
  //                                                 borderSide: BorderSide(color: Colors.blue),
  //                                               ),
  //                                               errorBorder: OutlineInputBorder(
  //                                                 borderRadius: BorderRadius.circular(10),
  //                                                 borderSide: BorderSide(color: Colors.red),
  //                                               ),
  //                                               focusedErrorBorder: OutlineInputBorder(
  //                                                 borderRadius: BorderRadius.circular(10),
  //                                                 borderSide: BorderSide(color: Colors.red),
  //                                               ),
  //                                               fillColor: Colors.white,
  //                                               filled: true,
  //                                             ),
  //                                             style: TextStyle(color: Colors.black),
  //                                             validator: (value) {
  //                                               if (value == null || value.trim().isEmpty) {
  //                                                 return "Please enter your request";
  //                                               }
  //                                               return null;
  //                                             },
  //                                           ),
  //                                           SizedBox(height: 20),
  //
  //                                           Row(
  //                                             mainAxisAlignment: MainAxisAlignment.center,
  //                                             children: [
  //                                               batan(
  //                                                 title: "Yes",
  //                                                 route: () async {
  //                                                   if (_formKey.currentState!.validate()) {
  //                                                     setDialogState(() {
  //                                                       isLoading = true;
  //                                                     });
  //                                                     setState(() {
  //                                                       busnessviewmodal!.data!.events![index].requestEvent = "pending";
  //                                                     });
  //                                                     await sendlistap(eventId);
  //                                                     setDialogState(() {
  //                                                       isLoading = false; // Stop loader
  //                                                     });
  //                                                     Get.back();
  //                                                   }
  //                                                 },
  //                                                 radius: 4.0.w,
  //                                                 color: AppColors.maincolor,
  //                                                 fontcolor: AppColors.white,
  //                                                 height: 6.h,
  //                                                 width: Get.width * .65,
  //                                                 fontsize: 19.sp,
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                   ),
  //                                 );
  //                               },
  //                             );
  //                           },
  //                         );
  //                       },
  //                       child: busnessviewmodal?.data?.events?[index]?.requestEvent?.toLowerCase() == "pending"
  //                           ? Text(
  //                         "Requested",
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.orange,
  //                         ),
  //                       )
  //                           : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             }
  //         );
  //       }),
  //     ],
  //   );
  // }
  Widget buildProductList(List<Products> products) {
    if (busnessviewmodal?.data?.products == null ||
        busnessviewmodal!.data!.products!.isEmpty) {
      return Center();
    }

    // Return Column instead of SizedBox to avoid nested scrolling issues
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(products.length, (index) {
          final product = products[index];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 4.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                onTap: () {
                  // print("Product Detail ID Ave che che ${product.id ?? ''}");
                  Get.to(
                    () => ProductDetailPage(
                      productID: product.id.toString() ?? "",
                      type: "product",
                    ),
                  );
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                // leading: ClipRRect(
                //   borderRadius: BorderRadius.circular(8),
                //   child: CachedNetworkImage(
                //     imageUrl: product.image ?? '',
                //     width: 60,
                //     height: 60,
                //     fit: BoxFit.cover,
                //     placeholder: (context, url) => Container(
                //       width: 60,
                //       height: 60,
                //       color: Colors.grey[300],
                //       child: const Center(
                //           child: CircularProgressIndicator(strokeWidth: 2)),
                //     ),
                //     errorWidget: (context, url, error) => Container(
                //       width: 60,
                //       height: 60,
                //       color: Colors.grey[300],
                //       child: const Icon(Icons.error, color: Colors.red),
                //     ),
                //   ),
                // ),
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
                    SizedBox(height: 4),
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
                        if (product.offerPrice != null) SizedBox(width: 6),
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
                    SizedBox(height: 4),
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
                trailing: Icon(
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

  // Helper Methods - આ methods તમારા class માં add કરો

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

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      decoration:
          isToday
              ? BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
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
                color: isToday ? Colors.blue : Colors.black87,
              ),
            ),
            Text(
              _getHoursText(dayHours),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.blue : Colors.grey[600],
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
}

Widget buildListTile({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 25, color: Colors.black54),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      ],
    ),
  );
}
