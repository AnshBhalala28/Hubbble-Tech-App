import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Screen/Authcation/Provider/authcation_provider.dart';
import 'package:wavee/Screen/Authcation/model/login_model.dart';
import 'package:wavee/Screen/Community Screen/Community Screen/Provider/community_provider.dart';
import 'package:wavee/Screen/Message_board/Provider/messsage_board_provider.dart';
import 'package:wavee/Screen/NotiFicationPage/Provider/notificationprovider.dart';
import 'package:wavee/Screen/Parcel/Provider/parcel_provider.dart';
import 'package:wavee/comman/welcome_screen.dart';
import 'Screen/HomeNewPage/Provider/homescreen_provider.dart';
import 'Screen/ViewProfile/Provider/profile_provider.dart';
import 'comman/locationServices.dart';
import 'comman/store_local.dart';

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..backgroundColor = Colors.blue
    ..progressColor = Colors.blue
    ..indicatorType = EasyLoadingIndicatorType.ripple
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskColor = Colors.blue
    ..userInteractions = false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  LoginModel? loginModel = await SaveDataLocal.getDataFromLocal();
  await LocationService().requestLocationPermission();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ParcelProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MessageBoardProvider()),
      ],
      child: MyApp(loginModel: loginModel),
    ),
  );
}

class MyApp extends StatelessWidget {
  final LoginModel? loginModel;

  const MyApp({super.key, this.loginModel});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wavee',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: WelcomeScreen(),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
