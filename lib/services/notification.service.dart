import "dart:async";
import "dart:convert";
import "dart:developer";
import "dart:io";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:get/get.dart";
import "package:get/get_core/src/get_main.dart";
import "package:manager/api_endpoints.dart";
import "package:manager/features/chat/video_chat/demo/call_screen.dart";
import "package:manager/features/stage/widgets/call_requiest_dialog.dart";
import "package:manager/routes/routes.dart";
import "package:manager/core/storage/storage.dart";
import "package:manager/services/chat.service.dart";
import "package:stacked_services/stacked_services.dart";

import "../core/locator.dart";
import "../features/chat/chat_view.dart";
import "../features/tickets/ticket_details/ticket_details.view.dart";
import "api.service.dart";


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const String _defaultChannelId = "triq_custom_sound_channel";
const String _defaultChannelName = "Triq Notifications";
const String _defaultChannelDescription = "Channel for Triq manager notifications";

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
    ) async {
  var payload = notificationResponse.payload;
  if (kDebugMode) {
    print("onDidReceiveNotificationResponse: $payload");
  }
  if (payload != null) {
    var jsonData = jsonDecode(payload);
    FirebaseNotificationService.notificationNavigation(data: jsonData);
  }
}

final List<String> _soundList = [
  'bamboo',
  'bell',
  'chime',
  'ding',
  'notification',
  'pop',
  'ring',
  'tone',
  'whistle',
];

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  // Isolate me Firebase ko initialize karna zaroori hai
  await Firebase.initializeApp();
  await _initializeLocalNotifications(isBackground: true);

  if (kDebugMode) {
    print("Background message received. Showing notification manually...");
    print("Background data: ${message.data}");
  }

  // Notification dikhane ke liye function call karein
  FirebaseNotificationService.showNotification(message);
}

Future<void> _initializeLocalNotifications({bool isBackground = false}) async {
  var androidSettings = const AndroidInitializationSettings(
    "@mipmap/ic_launcher",
  );
  var iOSSettings = const DarwinInitializationSettings();
  var initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iOSSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse:
    isBackground ? null : onDidReceiveNotificationResponse,
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  // 1. Default Channel
  var defaultChannel = const AndroidNotificationChannel(
    _defaultChannelId,
    _defaultChannelName,
    description: _defaultChannelDescription,
    importance: Importance.max,
    playSound: true,
  );
  await androidPlugin?.createNotificationChannel(defaultChannel);

  for (String soundName in _soundList) {
    final channelId = 'triq_sound_$soundName';
    final channelName = 'Triq ($soundName)';
    final channelDesc = 'Notification channel for $soundName sound';

    var soundChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      sound: RawResourceAndroidNotificationSound(soundName),
    );

    await androidPlugin?.createNotificationChannel(soundChannel);
  }
}



class FirebaseNotificationService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static var isSound = false;
  static int item = 1;
  static bool _isInitializing = false;
  static bool _isInitialized = false;

  static Future<void> initializeService() async {
    // Check initialization status
    if (_isInitializing || _isInitialized) {
      return;
    }
    _isInitializing = true;

    try {
      final settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('Permission status: ${settings.authorizationStatus}');
      }

      // Local Notification Init
      await _initializeLocalNotifications(isBackground: false);

      // 1. Background Handler yahan set karein (Sirf Ek Baar)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Foreground Listeners set karein
      getNotification();

      String? apnsToken;
      if (Platform.isIOS) {
        apnsToken = await _waitForApnsToken(timeout: const Duration(seconds: 6));
      }

      if (!Platform.isIOS || (apnsToken != null && apnsToken.isNotEmpty)) {
        final String? token = await firebaseMessaging.getToken();
        if (token != null) {
          // Save token logic
          final currentUser = getUser();
          if (currentUser.fcmToken == null) {
            saveUser(currentUser.copyWith(fcmToken: token));
          }
        }
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print("Error init: $e");
    } finally {
      _isInitializing = false;
    }
  }

  static getNotification() {
    // --- FIX: Yahan se onBackgroundMessage HATA diya gaya hai ---

    // Foreground Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Foreground message: ${message.data}");
      }
      // Foreground me notification dikhayein
      showNotification(message);
    });

    // App Open Listener
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      notificationNavigation(data: message.data);
    });
  }

  static showNotification(RemoteMessage message) async {

    String soundName = message.data['sound'] ?? 'default';
    if (soundName == 'noification') soundName = 'notification';

    // Title/Body Data se lein
    String title = message.data['title'] ?? message.notification?.title ?? 'New Notification';
    String body = message.data['body'] ?? message.notification?.body ?? '';

    String? iosSound = (soundName == 'default') ? 'default' : '$soundName.aiff';

    String androidChannelId;
    if (soundName == 'default' || !_soundList.contains(soundName)) {
      androidChannelId = _defaultChannelId;
    } else {
      androidChannelId = 'triq_sound_$soundName';
    }

    var android = AndroidNotificationDetails(
      androidChannelId,
      _defaultChannelName,
      priority: Priority.high,
      importance: Importance.max,
      // Channel Action (Sound) ensure karein
      playSound: true,
    );

    var iOS = DarwinNotificationDetails(
      sound: iosSound,
      presentSound: true,
    );

    var platform = NotificationDetails(android: android, iOS: iOS);
    var jsonData = jsonEncode(message.data);

    await flutterLocalNotificationsPlugin.show(
      item++, // Unique ID taaki notifications overwrite na hon
      title,
      body,
      platform,
      payload: jsonData,
    );
  }

  // ... baaki methods same rahenge (navigation, etc.) ...
  static notificationNavigation({data}) async {
    // Aapka purana logic same rahega
    String screenName = data["screenName"] ?? '';
    final _navigationService = locator<NavigationService>();

    if (screenName != '') {
      if (screenName == "chatView") {

        final String? contactName = data['contactName'];
        final String? contactNumber = data['ticketNumber'];
        final String? roomId = data['roomId'];
        final String? ticketStatus = data['ticketStatus'];
        final String? ticketId = data['ticketId'];
        final String? flag = data['flag'];

        final String contactInitials =
        (contactName != null && contactName.isNotEmpty)
            ? contactName[0].toUpperCase()
            : '?';

        if (contactName != null && roomId != null && ticketId != null) {
          _navigationService.navigateToView(
            ChatView(
              contactName: contactName,
              contactNumber: contactNumber ?? '',
              contactInitials: contactInitials,
              roomId: roomId,
              ticketStatus: ticketStatus ?? '',
              ticketId: ticketId,
              flag: flag,
            ),
          );
        }
      }
      else if (screenName == "TicketDetailsView") {
        final String? ticketId = data['ticketId'];
        if (ticketId != null) {
          _navigationService.navigateToView(
            TicketDetailsView(ticketId: ticketId),
          );
        }
      }
      else if (screenName == "video_call_view" || screenName == "audio_call_view") {


        final String? roomId = data['room_id'];
        final String? ticketStatus = data['ticketStatus'];
        final String? ticketId = data['ticketId'];
        String sender_name=data['sender_name'];
        String receiver_name=data['receiver_name'];
        final String? flag = data['flag'];
        final String? profile_pic = data['profile_pic'];
        final String? eventType = data['eventType'];
        final String? callType = data['callType'];
        final String? token = data['roomToken'];
        final String? user_id = data['user_id'];
        bool isVoice=callType=='audio';


          await _navigationService.navigateToView(
            ChatView(
              contactName: sender_name,
              contactNumber: '',
              contactInitials: sender_name.substring(0, 1).toUpperCase()??"",
              roomId: roomId,
              ticketStatus: ticketStatus ?? '',
              ticketId: ticketId,
              flag: flag,
              incomingCallData: data
            ),
          );

      }
      else {
        // If screenName doesn't match any known type, redirect to Notification screen
        _navigationService.navigateTo(Routes.notification);
      }
    } else {
      // If no screenName provided, redirect to Notification screen by default
      _navigationService.navigateTo(Routes.notification);
    }
  }



  static Future<String?> _waitForApnsToken({required Duration timeout}) async {

    try {
      final immediate = await firebaseMessaging.getAPNSToken();
      if (immediate != null && immediate.isNotEmpty) return immediate;
      final completer = Completer<String?>();
      final end = DateTime.now().add(timeout);
      Timer.periodic(const Duration(milliseconds: 300), (t) async {
        final tkn = await firebaseMessaging.getAPNSToken();
        if (tkn != null && tkn.isNotEmpty) {
          t.cancel();
          completer.complete(tkn);
        } else if (DateTime.now().isAfter(end)) {
          t.cancel();
          completer.complete(null);
        }
      });
      return completer.future;
    }
    catch (e) {
      return null;
    }

  }
}
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await FirebaseNotificationService.initializeService();
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final apiService = locator<ApiService>();
      final response = await apiService.get(url: ApiEndpoints.getUnreadNotificationCount);
      
      if (response.statusCode == 200) {
        // Check if response.data is a Map with unreadCount
        if (response.data is Map && response.data.containsKey('unreadCount')) {
          return response.data['unreadCount'] ?? 0;
        }
        // Fallback: if response.data is a List, count manually
        else if (response.data is List) {
          final List<dynamic> notificationList = response.data;
          final unreadCount = notificationList.where((notification) {
            return notification['isRead'] == false || notification['isRead'] == null;
          }).length;
          return unreadCount;
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) print('Error getting unread notification count: $e');
      return 0;
    }
  }


  // notification read
  // Get unread notification count
    Future<int> getUnReadMarkNotificationAsRead({String? id}) async {
    try {
      final apiService = locator<ApiService>();
      final response = await apiService.get(url: "${ApiEndpoints.getMarkNotificationAsRead}/$id");
print("response:- ${response}");

      if (response.statusCode == 200) {
        // Check if response.data is a Map with unreadCount
        // if (response.data is Map && response.data.containsKey('unreadCount')) {
        //   return response.data['unreadCount'] ?? 0;
        // }
        // Fallback: if response.data is a List, count manually
        // else if (response.data is List) {
        //   final List<dynamic> notificationList = response.data;
        //   final unreadCount = notificationList.where((notification) {
        //     return notification['isRead'] == false || notification['isRead'] == null;
        //   }).length;
        //   return unreadCount;
        // }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) print('Error getting unread notification count: $e');
      return 0;
    }
  }
  Future<String?> getToken({Duration waitTimeout = const Duration(seconds: 10)}) async {
    final firebase = FirebaseNotificationService.firebaseMessaging;

    final Completer<String?> tokenCompleter = Completer();
    StreamSubscription<String>? refreshSub;
    refreshSub = firebase.onTokenRefresh.listen((newToken) {
      if (!tokenCompleter.isCompleted) {
        tokenCompleter.complete(newToken);
      }
    }, onError: (err) {
      if (!tokenCompleter.isCompleted) tokenCompleter.completeError(err);
    });

    try {
      // On iOS, ensure APNs token is available; otherwise getToken() will throw.
      if (Platform.isIOS) {
        final apns = await firebase.getAPNSToken();
        if (apns == null || apns.isEmpty) {
          if (kDebugMode) print('APNs token not available yet — waiting up to $waitTimeout for FCM token via onTokenRefresh.');

          // Wait for onTokenRefresh (tokenCompleter) or timeout
          String? fallbackToken;
          try {
            fallbackToken = await tokenCompleter.future.timeout(waitTimeout, onTimeout: () {
              if (kDebugMode) print('Timed out waiting for token via onTokenRefresh.');
              return null;
            });
          } catch (e) {
            if (kDebugMode) print('Error while waiting for onTokenRefresh: $e');
            fallbackToken = null;
          } finally {
            await refreshSub?.cancel();
          }

          if (fallbackToken != null) {
            if (kDebugMode) print('Received token from onTokenRefresh: $fallbackToken');
            return fallbackToken;
          }

          // If still no token, return null (avoid calling getToken() now)
          if (kDebugMode) print('No token available (APNs missing). Returning null.');
          return null;
        }
      }

      // If non-iOS or APNs exists, call getToken() in try/catch.
      try {
        final token = await firebase.getToken();
        if (kDebugMode) print('FCM token (immediate): $token');
        await refreshSub?.cancel();
        return token;
      } catch (e) {
        // If getToken throws apns-token-not-set, fallback to waiting for onTokenRefresh
        if (kDebugMode) print('getToken() threw: $e — falling back to onTokenRefresh wait.');
        try {
          final fallback = await tokenCompleter.future.timeout(waitTimeout, onTimeout: () {
            if (kDebugMode) print('Timed out waiting for fallback token.');
            return null;
          });
          if (kDebugMode) print('Fallback token from onTokenRefresh: $fallback');
          return fallback;
        } finally {
          await refreshSub?.cancel();
        }
      }
    } finally {
      // Ensure subscription cleaned if completer already resolved earlier
      await refreshSub?.cancel();
    }
  }


}