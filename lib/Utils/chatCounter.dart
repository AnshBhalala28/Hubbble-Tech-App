import 'dart:async';

import 'package:get/get.dart';

import '../ui/home_screen/modal/chatShowCountModal.dart';
import '../ui/home_screen/modal/parcelShowCount.dart';
import '../ui/home_screen/modal/visitorShowCountModel.dart';
import '../ui/home_screen/provider/homescreenProvider.dart';
import 'checkInternetConnection.dart';
import 'const.dart'; // Tamari const file

enum ApiState { idle, loading, success, error, rateLimited }

class GlobalCountsController extends GetxController {
  var chatCount = 0.obs;
  var visitorCount = 0.obs;
  var parcelCount = 0.obs;
  var apiState = ApiState.idle.obs;

  Timer? _periodicTimer; // 3-second valo timer
  Timer? _rateLimitTimer; // 60-second valo pause timer

  bool _isPollingActive = false; // Aa 'HomePage' thi control thase
  DateTime? _lastApiCallTime;
  bool _isPausedForRateLimit = false;

  @override
  void onInit() {
    super.onInit();
    print('GlobalCountsController Initialized');
  }

  @override
  void onClose() {
    _cancelPeriodicTimer();
    _rateLimitTimer?.cancel();
    print('GlobalCountsController Disposed');
    super.onClose();
  }

  void _initializeData() {
    _fetchCountData(force: true);
  }

  void startApiPolling() {
    if (_isPollingActive) return;
    print('GlobalCountsController: Polling Started by HomePage');
    _isPollingActive = true;
    _initializeData();
  }

  void stopApiPolling() {
    if (!_isPollingActive) return;
    print('GlobalCountsController: Polling Stopped by HomePage');
    _isPollingActive = false;
    _cancelPeriodicTimer();
    _rateLimitTimer?.cancel(); // Rate limit timer pan bandh karo
  }

  // (Internal functions)
  void _startPeriodicTimer() {
    _cancelPeriodicTimer(); // Pehla no koi timer hoy to bandh karo
    if (!_isPollingActive) {
      return; // Jo polling bandh thai gayu hoy to chalu na karo
    }

    _periodicTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isPollingActive) {
        _fetchCountData();
      }
    });
  }

  void _cancelPeriodicTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  void _fetchCountData({bool force = false}) {
    // Jo polling bandh hoy, rate limit chalu hoy, athva loading chalu hoy to navo call na karo
    if (!_isPollingActive) return;
    if (_isPausedForRateLimit) return;
    if (apiState.value == ApiState.loading && !force) return;

    final now = DateTime.now();
    if (_lastApiCallTime != null &&
        now.difference(_lastApiCallTime!).inSeconds < 2 &&
        !force) {
      return;
    }

    _lastApiCallTime = now;
    _performApiFetches();
  }

  Future<void> _performApiFetches() async {
    if (apiState.value == ApiState.loading) return;
    apiState.value = ApiState.loading;

    try {
      final results = await Future.wait([
        ChatShowCount(),
        ParcelShowCount(),
        VisitorShowCount(),
      ]);

      if (results.contains('429')) {
        apiState.value = ApiState.rateLimited;
        _handleRateLimit(); // 🔥 429 AAVE TYARE NAVO LOGIC
      } else if (results.contains('error')) {
        apiState.value = ApiState.error;
        _startPeriodicTimer(); // Error ave to pan, 3 sec pachi try karo
      } else {
        apiState.value = ApiState.success;
        _startPeriodicTimer(); // 🔥 SUCCESS PAR J TIMER CHALU KARO
      }
    } catch (e) {
      print('Error in _performApiFetches: $e');
      apiState.value = ApiState.error;
      _startPeriodicTimer(); // Catch ma pan timer chalu rakho
    }
  }

  // 🔥 AA CHHE TAMARO FINAL 429 FIX
  void _handleRateLimit() {
    if (_isPausedForRateLimit) {
      return; // Jo pela thi j pause chhe to kai na karo
    }

    _isPausedForRateLimit = true;
    _lastApiCallTime = DateTime.now();
    print('Rate limit detected, STOPPING timer for 60 seconds');

    // 1. 3-second valo timer TURANT bandh karo
    _cancelPeriodicTimer();

    // 2. 60-second no ONE-TIME timer chalu karo
    _rateLimitTimer?.cancel(); // Juno koi hoy to kadhi nakho
    _rateLimitTimer = Timer(const Duration(seconds: 60), () {
      print('60-second pause ended. Trying one more fetch.');
      _isPausedForRateLimit = false;

      // Fakt ek vaar try karo.
      // Jo aa 'success' thase, to _performApiFetches
      // potani rite j _startPeriodicTimer() ne call kari dese.
      // Jo '429' avse, to e paacho ahi j avse.
      if (_isPollingActive) {
        _fetchCountData(force: true);
      }
    });
  }

  // (Tamara badha API call functions - ChatShowCount, etc. - jem chhe em j)
  Future<String> ChatShowCount() async {
    if (loginModel?.data?.user?.id == null) return 'error';
    final Map<String, String> bodyData = {
      'sender_id': '1',
      'receiver_id': loginModel!.data!.user!.id.toString(),
    };
    bool internet = await checkInternet();
    if (!internet) return 'error';
    try {
      final response = await HomeProvider().chatCountApi(bodyData);
      if (response.statusCode == 429) {
        return '429';
      }
      if (response.statusCode == 200) {
        chatShowCountModal = ChatShowCountModal.fromJson(response.data);
        chatCount.value = chatShowCountModal?.data ?? 0;
        return 'success';
      }
      return 'error';
    } catch (error) {
      print('ChatShowCount error: $error');
      return 'error';
    }
  }

  Future<String> ParcelShowCount() async {
    if (loginModel?.data?.user?.id == null) return 'error';
    final Map<String, String> bodyData = {
      "user_id": loginModel!.data!.user!.id.toString(),
      "type": "count",
    };
    bool internet = await checkInternet();
    if (!internet) return 'error';
    try {
      final response = await HomeProvider().parcelShowCountApi(bodyData);
      if (response.statusCode == 429) {
        return '429';
      }
      if (response.statusCode == 200) {
        parcelShowCountModel = ParcelShowCountModel.fromJson(response.data);
        parcelCount.value = parcelShowCountModel?.data ?? 0;
        return 'success';
      }
      return 'error';
    } catch (error) {
      print('ParcelShowCount error: $error');
      return 'error';
    }
  }

  Future<String> VisitorShowCount() async {
    if (loginModel?.data?.user?.id == null) return 'error';
    final Map<String, String> bodyData = {
      "user_id": loginModel!.data!.user!.id.toString(),
      "count": "visitor",
    };
    bool internet = await checkInternet();
    if (!internet) return 'error';
    try {
      final response = await HomeProvider().visitorShowCountApi(bodyData);
      if (response.statusCode == 429) {
        return '429';
      }
      if (response.statusCode == 200) {
        visitorShowCountModel = VisitorShowCountModel.fromJson(response.data);
        visitorCount.value = visitorShowCountModel?.data ?? 0;
        return 'success';
      }
      return 'error';
    } catch (error) {
      print('VisitorShowCount error: $error');
      return 'error';
    }
  }
}
